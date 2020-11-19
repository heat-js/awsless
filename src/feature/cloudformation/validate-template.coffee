
import Client from '../client/cloudformation'

export default ({ profile, region, template }) ->

	cloudFormation = await Client { profile, region }
	result = await cloudFormation.validateTemplate {
		TemplateBody: template
	}
	.promise()

	return result.Capabilities
