
import Context from '../../context'
import Emitter from '../../emitter'

export default (template, customResources = {}) ->

	emitter = new Emitter
	context = new Context { template, emitter }

	for name, resource of template
		type			= resource.Type or ''
		customResource	= customResources[ type ]

		if customResource
			await customResource(
				context
				name
				resource.Properties or {}
			)

		else if 0 is type.indexOf 'AWS::'
			context.addResource name, resource

	return {
		context
		template: {
			AWSTemplateFormatVersion: '2010-09-09'
			Description:	"The AWS CloudFormation template for this Serverless application"
			Resources:		context.getResources()
			Outputs:		context.getOutputs()
		}
	}
