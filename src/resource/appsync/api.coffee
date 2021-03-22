
import resource 	from '../../feature/resource'
import loadFiles 	from '../../feature/appsync/load-files'
import { join }		from 'path'
import { run }		from '../../feature/terminal/task'
import time			from '../../feature/performance/time'
import { GetAtt, isArn, isFn, Sub }	from '../../feature/cloudformation/fn'

getDataSourceType = (item) ->
	return (
		if item.lambda then { key: item.lambda, type: 'lambda' }
		else { key: 'none', type: 'none' }
	)

toLambdaArn = (arn) ->
	if not isFn(arn) and not isArn(arn)
		return Sub "arn:${AWS::Partition}:lambda:${AWS::Region}:${AWS::AccountId}:function:#{ arn }"

	return arn

userPoolConfig = (ctx) ->
	config = ctx.object 'UserPoolConfig', {}
	if not Object.keys(config).length
		return {}

	return {
		UserPoolConfig: {
			AwsRegion:		ctx.string [ 'UserPoolConfig.AwsRegion', 'UserPoolConfig.Region', '@Config.Region' ]
			UserPoolId:		ctx.string 'UserPoolConfig.UserPoolId'
			DefaultAction:	ctx.string 'UserPoolConfig.DefaultAction', 'ALLOW'
		}
	}

resolver = (ctx, item) ->
	{ type } = getDataSourceType item
	dataSourceName = "#{ ctx.name }DataSource#{ item.id }"
	if type is 'none'
		dataSourceName = "#{ ctx.name }DataSourceNone"

	ctx.addResource "#{ ctx.name }Resolver#{ item.id }", {
		Type:		'AWS::AppSync::Resolver'
		Region:		ctx.string '#Region', ''
		DependsOn:	"#{ ctx.name }Schema"
		Properties: {
			ApiId:						GetAtt ctx.name, 'ApiId'
			Kind:						'UNIT'
			TypeName:					item.type
			FieldName:					item.field
			RequestMappingTemplate:		item.request
			ResponseMappingTemplate:	item.response
			DataSourceName:				GetAtt dataSourceName, 'Name'
		}
	}

dataSourceNone = (ctx) ->
	ctx.addResource "#{ ctx.name }DataSourceNone", {
		Type:		'AWS::AppSync::DataSource'
		Region:		ctx.string '#Region', ''
		DependsOn:	"#{ ctx.name }Schema"
		Properties: {
			ApiId:	GetAtt ctx.name, 'ApiId'
			Name:	'None'
			Type:	'NONE'
		}
	}

dataSourceLambda = (ctx, item) ->
	ctx.addResource "#{ ctx.name }DataSource#{ item.id }", {
		Type:		'AWS::AppSync::DataSource'
		Region:		ctx.string '#Region', ''
		DependsOn:	"#{ ctx.name }Schema"
		Properties: {
			ApiId:	GetAtt ctx.name, 'ApiId'
			Name:	item.id
			Type:	'AWS_LAMBDA'
			ServiceRoleArn:			GetAtt "#{ ctx.name }ServiceRole", 'Arn'
			LambdaConfig:
				LambdaFunctionArn:	toLambdaArn item.lambda
		}
	}

dataSource = (ctx, item, cache) ->
	{ key, type } = getDataSourceType item
	key = JSON.stringify key
	if cache.includes key
		return

	cache.push key
	switch type
		when 'lambda' then dataSourceLambda ctx, item
		else dataSourceNone ctx

lambdaPolicy = (resolvers) ->
	return {
		Effect: 'Allow'
		Action: 'lambda:invokeFunction'
		Resource: resolvers
			.filter ({ lambda }) -> lambda
			.map ({ lambda }) ->
				return toLambdaArn lambda
	}

role = (ctx, resolvers) ->
	ctx.addResource "#{ ctx.name }ServiceRole", {
		Type:		'AWS::IAM::Role'
		Region:		ctx.string '#Region', ''
		Properties: {
			AssumeRolePolicyDocument: {
				Version: '2012-10-17'
				Statement: [{
					Effect: 'Allow'
					Action: 'sts:AssumeRole'
					Principal: {
						Service: 'appsync.amazonaws.com'
					}
				}]
			}

			Policies: [{
				PolicyName: "#{ ctx.name }-Service-Role"
				PolicyDocument: {
					Version: '2012-10-17'
					Statement: [
						lambdaPolicy resolvers
					]
				}
			}]
		}
	}

export default resource (ctx) ->

	name		= ctx.string 'Name'
	region		= ctx.string '#Region', ''
	sourceFiles	= ctx.string [ 'Path', 'Src', 'Source', 'SourceFiles' ]
	sourceFiles	= join process.cwd(), sourceFiles

	mappingTemplates = ctx.string 'MappingTemplates', ''
	if mappingTemplates
		mappingTemplates = join process.cwd(), mappingTemplates

	ctx.addResource ctx.name, {
		Type:	'AWS::AppSync::GraphQLApi'
		Region:	region
		Properties: {
			Name:					name
			AuthenticationType:		ctx.string 'AuthenticationType'
			XrayEnabled:			ctx.boolean [ 'Xray', 'XrayEnabled' ], false

			...userPoolConfig ctx

			Tags: [
				...ctx.array 'Tags', []
				{ Key: 'AppsyncName', Value: name }
			]
		}
	}

	ctx.on 'prepare-resource', ->
		{ schema, resolvers } = await run (task) ->
			task.setPrefix 'AppSync API'
			task.setName name
			task.setContent 'Parsing graphql...'

			elapsed = time()

			result = await loadFiles sourceFiles, mappingTemplates

			task.setContent 'Parsed'
			task.addMetadata 'Resolvers', result.resolvers.length
			task.addMetadata 'Time', elapsed()
			return result

		ctx.addResource "#{ ctx.name }Schema", {
			Type:	'AWS::AppSync::GraphQLSchema'
			Region:	region
			Properties: {
				ApiId:			GetAtt ctx.name, 'ApiId'
				Definition:		schema
			}
		}

		cache = []
		role ctx, resolvers
		for item in resolvers
			resolver ctx, item
			dataSource ctx, item, cache
