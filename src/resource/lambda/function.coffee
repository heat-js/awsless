
import resource			from '../../feature/resource'
import uploadLambda		from '../../feature/lambda/upload'
import { Ref, GetAtt }	from '../../feature/cloudformation/fn'
import removeDirectory	from '../../feature/fs/remove-directory'
import path				from 'path'
import cron				from './event/cron'
import sns				from './event/sns'
import sqs				from './event/sqs'
import output			from '../output'

# iamRole = (ctx, name, region, logging, warmer, events) ->
# 	ctx.addResource "#{ ctx.name }IamRole", {
# 		Type: 'AWS::IAM::Role'
# 		Region: region
# 		Properties: {
# 			Path: '/'
# 			RoleName: "#{ stack }-#{ region }-#{ name }-lambda-role"
# 			AssumeRolePolicyDocument: {
# 				Version: '2012-10-17'
# 				Statement: [ {
# 					Effect: 'Allow'
# 					Principal: {
# 						Service: [ 'lambda.amazonaws.com' ]
# 					}
# 					Action: [ 'sts:AssumeRole' ]
# 				} ]
# 			}
# 			Policies: policies
# 			ManagedPolicyArns: [

# 			]
# 			# ManagedPolicyArns: ctx.ref ''
# 		}
# 	}

export default resource (ctx) ->

	stack	= ctx.string [ '#Stack',	'@Config.Stack' ]
	region	= ctx.string [ '#Region',	'@Config.Region' ]
	profile	= ctx.string [ '#Profile',	'@Config.Profile' ]

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
		}, { Region: region }

	for event, index in events
		event = { ...event, Postfix: String index }
		switch ctx.string "Events.#{ index }.Type"
			when 'CRON' then cron ctx, ctx.name, event
			when 'SNS'	then sns ctx, ctx.name, event
			when 'SQS'	then sqs ctx, ctx.name, event

	ctx.once 'cleanup', ->
		dir = path.join process.cwd(), '.awsless', 'lambda'
		await removeDirectory dir

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
				Handler:		"index#{ path.extname handle }"
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
