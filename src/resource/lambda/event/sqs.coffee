
import resource						from '../../../feature/resource'
import { GetAtt, Sub, isFn, isArn }	from '../../../feature/cloudformation/fn'

export default resource (ctx) ->

	Region	= ctx.string '#Region', ''
	postfix = ctx.string 'Postfix'
	queue	= ctx.string 'Queue'

	if not isFn(queue) and not isArn(queue)
		queue = Sub "arn:aws:sqs:${AWS::Region}:${AWS::AccountId}:#{ queue }"

	ctx.addResource "#{ ctx.name }SqsEventSourceMapping#{ postfix }", {
		Type: 'AWS::Lambda::EventSourceMapping'
		Region
		Properties: {
			FunctionName:	GetAtt ctx.name, 'Arn'
			Enabled:		true
			BatchSize:		ctx.number 'BatchSize', 1
			EventSourceArn: queue
		}
	}
