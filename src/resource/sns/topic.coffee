
import resource from '../../feature/resource'

export default resource (ctx) ->
	name = ctx.string [ 'Name', 'TopicName' ]
	ctx.addResource ctx.name, {
		Type:	'AWS::SNS::Topic'
		Region:	ctx.string '#Region', ''
		Properties: {
			TopicName: name
			Tags: [
				...ctx.array 'Tags', []
				{ Key: 'Topic', Value: name }
			]
		}
	}
