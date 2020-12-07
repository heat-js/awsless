
import resource from '../../feature/resource'

redrivePolicy = (ctx) ->
	deadLetter = ctx.string 'DeadLetterArn', ''
	if not deadLetter
		return {}

	return {
		RedrivePolicy: {
			maxReceiveCount: 5
			deadLetterTargetArn: deadLetter
		}
	}

export default resource (ctx) ->

	name = ctx.string [ 'Name', 'QueueName' ]

	ctx.addResource ctx.name, {
		Type:	'AWS::SQS::Queue'
		Region:	ctx.string '#Region', ''
		Properties: {
			QueueName:				name
			MessageRetentionPeriod: ctx.number 'MessageRetentionPeriod', 1209600
			VisibilityTimeout:		ctx.number 'VisibilityTimeout', 30

			...redrivePolicy ctx

			Tags: [
				...ctx.array 'Tags', []
				{ Key: 'QueueName', Value: name }
			]
		}
	}
