
import resource 	from '../../feature/resource'
import Client		from '../../feature/client/s3'

upload = ({ name, profile, region, stack, bucket, templateBody }) ->
	if not bucket
		throw new Error '''
			You need to set a "Config.DeploymentBucket" to handle Awsless::CloudFormation::Stack resources.
		'''

	s3 = Client { profile, region }

	result = await s3.putObject {
		Bucket: 		bucket
		Key:			"#{ stack }/#{ name }-nested-cloudformation.json"
		ACL:			'private'
		Body:			templateBody
		StorageClass:	'STANDARD'
	}
	.promise()

	return "https://s3-#{ region }.amazonaws.com/#{ bucket }/#{ stack }/#{ name }-nested-cloudformation.json"

timeoutInMinutes = (ctx) ->
	TimeoutInMinutes = ctx.number 'TimeoutInMinutes', -1
	if TimeoutInMinutes is -1
		return {}

	return { TimeoutInMinutes }

export default resource (ctx) ->

	stack		= ctx.string [ '#Stack',			'@Config.Stack' ]
	region		= ctx.string [ '#Region',			'@Config.Region' ]
	profile		= ctx.string [ '#Profile',			'@Config.Profile' ]
	bucket		= ctx.string [ 'DeploymentBucket',	'@Config.CloudFormation.DeploymentBucket', '@Config.DeploymentBucket' ]

	ctx.on 'prepare-resource', ->
		resources = ctx.string 'Resources'

		url = await upload {
			name:	ctx.name
			stack
			region
			profile
			bucket
			templateBody: {
				AWSTemplateFormatVersion: '2010-09-09'
				Description:	ctx.string 'Description', ''
				Resources:		ctx.object 'Resources'
				# Outputs:		ctx.object 'Outputs',
			}
		}

		ctx.addResource ctx.name, {
			Type:		'AWS::CloudFormation::Stack'
			Region:		ctx.string '#Region', ''
			DependsOn:	ctx.any '#DependsOn', ''
			Properties: {
				TemplateURL:		url
				Parameters:			ctx.object 'Parameters', {}
				Tags:				ctx.array 'Tags', []
				...timeoutInMinutes ctx
			}
		}
