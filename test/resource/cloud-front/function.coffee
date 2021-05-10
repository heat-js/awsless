
import Context		from '../../../src/context'
import cfFunction	from '../../../src/resource/cloud-front/function'

describe 'Resource CloudFront Function', ->

	it 'test', ->
		context = new Context { name: 'Test' }
		await cfFunction context, 'TestFunction', {
			Name: 	'test-function'
			Handle: 'src/resource/cloud-front/test/handler'
		}

		resources = context.getResources()
		expect Object.keys resources
			.toStrictEqual [
				'TestFunction'
			]
