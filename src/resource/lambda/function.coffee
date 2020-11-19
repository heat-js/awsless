
import resource			from '../../feature/resource'
import uploadLambda		from '../../feature/lambda/upload'
import { Ref, GetAtt }	from '../../feature/cloudformation/fn'
import path				from 'path'
import cron				from './event/cron'
import sns				from './event/sns'
import sqs				from './event/sqs'
import output			from '../output'

export default resource (ctx) ->

	stack	= ctx.string '@Config.Stack'
	region	= ctx.string '@Config.Region'
	profile	= ctx.string '@Config.Profile'

	bucket	= ctx.string [ 'DeploymentBucket', '@Config.Lambda.DeploymentBucket' ]
	name	= ctx.string 'Name'
	handle	= ctx.string 'Handle'
	logging	= ctx.boolean [ 'Logging', '@Config.Lambda.Logging' ], false
	warmer	= ctx.boolean [ 'Warmer', '@Config.Lambda.Warmer' ], false
	events	= ctx.array 'Events', []

	if logging
		ctx.addResource "#{ ctx.name }LogGroup", {
			Type: 'AWS::Logs::LogGroup'
			Region: region
			Properties: {
				LogGroupName:		"/aws/lambda/#{ name }"
				RetentionInDays:	ctx.boolean [ 'LogRetentionInDays', '@Config.Lambda.LogRetentionInDays' ], 14
			}
		}

	if warmer
		cron ctx, ctx.name, {
			Postfix:	'Warmer'
			Rate:		'rate(5 minutes)'
			Input:		{ warmer: true, concurrency: 3 }
		}

	for event, index in events
		event = { ...event, Postfix: String index }
		switch ctx.string "Events.#{ index }.Type"
			when 'CRON' then cron ctx, ctx.name, event
			when 'SNS'	then sns ctx, ctx.name, event
			when 'SQS'	then sqs ctx, ctx.name, event

	ctx.on 'prepare-resource', ->
		{ key, fileHash, zipHash, version } = await uploadLambda {
			stack
			profile
			region
			bucket
			handle
			name
		}

		ctx.addResource "#{ ctx.name }Version#{ fileHash }", {
			Type: 'AWS::Lambda::Version'
			Region: region
			DeletionPolicy: 'Retain'
			Properties: {
				FunctionName:	Ref ctx.name
				CodeSha256:		zipHash
			}
		}

		ctx.addResource ctx.name, {
			Type: 'AWS::Lambda::Function'
			Region: region
			Properties: {
				Code: {
					S3Bucket:			bucket
					S3Key:				key
					S3ObjectVersion:	version
				}
				FunctionName:	name
				Handler:		path.basename handle
				Role:			GetAtt 'LambdaPolicyIamRole', 'Arn'
				MemorySize:		ctx.number [ 'MemorySize', '@Config.Lambda.MemorySize' ], 128
				Runtime:		ctx.string [ 'Runtime', '@Config.Lambda.Runtime' ], 'nodejs12.x'
				Timeout:		ctx.number [ 'Timeout', '@Config.Lambda.Timeout' ], 30
				Environment: {
					Variables: {
						...ctx.object '@Config.Lambda.Env', {}
						...ctx.object 'Env', {}
					}
				}

				Tags: [
					...ctx.array 'Tags', []
					{ Key: 'FunctionName', Value: name }
				]
			}
		}



# export default class LambdaFunction extends Resource

# 	linkSns: (index, event) -> {}
# 	linkSqs: (index, event) -> {}
# 	linkCron: (index, event) -> {
# 		[ "#{ @name }_EventsRule_#{ index }" ]: {
# 			Type: 'AWS::Events::Rule'
# 			Properties: {
# 				State: 'ENABLED'
# 				ScheduleExpression: event.Rate
# 				Targets: [
# 					{
# 						Id:		@name
# 						Arn:	{ 'Fn::GetAtt': [ @name, 'Arn' ] }
# 						Input:	JSON.stringify event.Input
# 					}
# 				]
# 				...@tags()
# 			}
# 		}
# 		[ "#{ @name }_LambdaPermission_#{ index }" ]: {
# 			Type: 'AWS::Lambda::Permission'
# 			Properties: {
# 				FunctionName: { 'Fn::GetAtt': [ @name, 'Arn' ] }
# 				Action:	'lambda:InvokeFunction'
# 				Principal: 'events.amazonaws.com'
# 				SourceArn: { 'Fn::GetAtt': [ "#{ @name }_EventsRule_#{ index }", 'Arn' ] }
# 			}
# 		}
# 	}

# 	warmer: ->
# 		concurrency = @number 'Warmer', 0
# 		if not concurrency
# 			return {}

# 		return @linkCron 'Warmer', {
# 			Rate: 'rate(5 minutes)'
# 			Input: { warmer: true, concurrency }
# 		}

# 	events: ->
# 		resources = {}
# 		for event, index in @props.Events
# 			resources = {
# 				...resources
# 				...( switch event.Type
# 					when 'SNS'	then @linkSns index, event
# 					when 'SQS'	then @linkSqs index, event
# 					when 'CRON'	then @linkCron index, event
# 				)
# 			}

# 		return resources

# 	environmentVariables: -> {
# 		...( @vars.Lambda?.EnvironmentVariables or {} )
# 		...( @props.EnvironmentVariables or {} )
# 	}

# 	LogGroup: ->
# 		if not @boolean 'Logging', false
# 			return {}

# 		return {
# 			[ "#{ @name }_LogGroup" ]: {
# 				Type: "AWS::Logs::LogGroup",
# 				Properties: {
# 					LogGroupName:		"/aws/lambda/#{ @props.Name }",
# 					RetentionInDays:	14
# 				}
# 			}
# 		}

# 	resources: -> {
# 		[ @name ]: {
# 			Type: 'AWS::Lambda::Function'
# 			Properties: {
# 				Code: {
# 					S3Bucket:	@string 'DeploymentBucket', 'deployments.${var:profile}.${var:region}'
# 					S3Key:		'serverless/wheel/prod/1605198388359-2020-11-12T16:26:28.359Z/spin.zip'
# 				}
# 				FunctionName:	@props.Name
# 				Handler:		@props.Handler
# 				MemorySize:		@number 'MemorySize', 128
# 				Role:			{ 'Fn::GetAtt': [ 'IamRoleLambdaExecution', 'Arn' ] }
# 				Runtime:		@string 'Runtime', 'nodejs12.x'
# 				Timeout:		@number 'Timeout', 30
# 				Environment:	{ Variables: @environmentVariables() }

# 				...@tags { FunctionName: @props.Name }
# 			}
# 		}
# 		[ "#{ @name }_LambdaVersion_#{ Date.now() }" ]: {
# 			Type: 'AWS::Lambda::Version'
# 			DeletionPolicy: 'Retain'
# 			Properties: {
# 				FunctionName:	{ Ref: @name }
# 				CodeSha256:		@hash
# 			}
# 		}
# 		@events()
# 		@warmer()
# 		@LogGroup()
# 	}

# 	outputs: -> {
# 		[ "#{ @name }_Arn" ]: {
# 			Description: 'The Arn of the Lambda Function'
# 			Value: { 'Fn::GetAtt': [ @name, 'Arn' ] }
# 			Export: {
#       			Name: "#{ @vars.name }-#{ @name }-Arn"
# 			}
# 		}
# 		[ "#{ @name }_ArnVersioned" ]: {
# 			Description: 'The Versioned Arn of the Lambda Function'
# 			Value: { Ref: @name ] }
# 			Export: {
#       			Name: "#{ @vars.name }-#{ @name }-ArnVersioned"
# 			}
# 		}
# 	}
