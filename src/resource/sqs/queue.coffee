
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
	# console.log ctx
	# console.log ctx.array 'Tags', []
	ctx.addResource ctx.name, {
		Type: 'AWS::SQS::Queue'
		Properties: {
			QueueName:				ctx.string 'Name'
			MessageRetentionPeriod: ctx.number 'MessageRetentionPeriod', 1209600
			VisibilityTimeout:		ctx.number 'VisibilityTimeout', 30

			...redrivePolicy ctx

			Tags: [
				...ctx.array 'Tags', []
				{ Key: 'QueueName', Value: ctx.string 'Name' }
			]
		}
	}
