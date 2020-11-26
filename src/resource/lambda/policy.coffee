

import resource				from '../../feature/resource'
import { Sub, isFn, isArn }	from '../../feature/cloudformation/fn'
import objectPath			from '../../feature/object-path'

logPolicy = (ctx) ->
	functions	= ctx.find 'Custom::Lambda::Function'
	createLogs	= []
	putLogs		= []

	for item in functions
		name = objectPath {
			properties:	item.Properties
			paths:		'Name'
			type:		'string'
		}

		logging = objectPath {
			template:		ctx.template
			properties:		item.Properties
			paths:			[ 'Logging', '@Config.Lambda.Logging' ]
			type:			'boolean'
			defaultValue:	false
		}

		if logging
			arn = "arn:${AWS::Partition}:logs:${AWS::Region}:${AWS::AccountId}:log-group:/aws/lambda/#{ name }"
			createLogs.push Sub "#{ arn }:*"
			putLogs.push	Sub "#{ arn }:*:*"

	if not createLogs.length
		return []

	return [ {
		PolicyName: "logging-lambda"
		PolicyDocument: {
			Version: '2012-10-17'
			Statement: [
				{
					Effect: 'Allow'
					Action: [ 'logs:CreateLogStream', 'logs:CreateLogGroup' ]
					Resource: createLogs
				}
				{
					Effect: 'Allow'
					Action: [ 'logs:PutLogEvents' ]
					Resource: putLogs
				}
			]
		}
	} ]

customPolicies = (ctx) ->
	return ctx
		.find 'Custom::Lambda::Policy'
		.map (item) -> {
			PolicyName: "#{ item.Name }-lambda"
			PolicyDocument: {
				Version:	item.Version or '2012-10-17'
				Statement:	item.Properties
			}
		}

warmerPolicy = (ctx) ->
	rules = ctx.find 'Custom::Lambda::Function'
		.filter (item) ->
			return objectPath {
				template:		ctx.template
				properties:		item.Properties
				paths:			[ 'Warmer', '@Config.Lambda.Warmer' ]
				type:			'boolean'
				defaultValue:	false
			}
		.map (item) ->
			name = objectPath {
				properties:	item.Properties
				paths:		'Name'
				type:		'string'
			}

			return Sub "arn:${AWS::Partition}:lambda:${AWS::Region}:${AWS::AccountId}:function:/aws/lambda/#{ name }"

	if rules.length is 0
		return []

	return [ {
		PolicyName: "warmer-lambda"
		PolicyDocument: {
			Version: '2012-10-17'
			Statement: [
				{
					Effect: 'Allow'
					Action: [ 'lambda:InvokeFunction' ]
					Resource: rules
				}
			]
		}
	} ]

sqsPolicy = (ctx) ->
	queues = ctx.find 'Custom::Lambda::Function'
		.map (item) ->
			return objectPath {
				properties:		item.Properties
				paths:			'Events'
				type:			'array'
				defaultValue:	[]
			}

		.flat()
		.filter (item) ->
			return item.Type is 'SQS'

		.map (item) ->
			return item.Queue

		.map (queue) ->
			if not isFn(queue) and not isArn(queue)
				return Sub "arn:aws:sqs:${AWS::Region}:${AWS::AccountId}:#{ queue }"

			return queue

	if queues.length is 0
		return []

	return [ {
		PolicyName: "sqs-events-lambda"
		PolicyDocument: {
			Version: '2012-10-17'
			Statement: [
				{
					Effect: 'Allow'
					Action: [
						'sqs:ReceiveMessage'
						'sqs:DeleteMessage'
						'sqs:GetQueueAttributes'
					]
					Resource: queues
				}
			]
		}
	} ]

export default resource (ctx) ->

	ctx.once 'prepare-resource', ->
		stack	= ctx.string '@Config.Stack'
		Region	= ctx.string [ '#Region', '@Config.Region' ]

		policies = [
			...logPolicy ctx
			...warmerPolicy ctx
			...customPolicies ctx
			...sqsPolicy ctx
		]

		if policies.length is 0
			return

		ctx.addResource "LambdaPolicyIamRole", {
			Type: 'AWS::IAM::Role'
			Region
			Properties: {
				Path: '/'
				RoleName: "#{ stack }-#{ Region }-lambda-role"
				AssumeRolePolicyDocument: {
					Version: '2012-10-17'
					Statement: [ {
						Effect: 'Allow'
						Principal: {
							Service: [ 'lambda.amazonaws.com' ]
						}
						Action: [ 'sts:AssumeRole' ]
					} ]
				}
				Policies: policies
			}
		}
