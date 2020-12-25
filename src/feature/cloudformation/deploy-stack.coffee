
import Client 			from '../client/cloudformation'
import { warn }			from '../console'
import stackStatus 		from './stack-status'
import stackEventsError from './stack-events-error'

export default ({ profile, region, stack, template, capabilities = [] }) ->

	cloudFormation = Client { profile, region }

	params = {
		StackName: stack
		TemplateBody: template
		Capabilities: capabilities
		Tags: [ { Key: 'Stack', Value: stack } ]
	}

	status = await stackStatus { profile, region, stack }
	exists = !!status
	if not exists
		result = await cloudFormation.createStack {
			...params
			EnableTerminationProtection: false
			OnFailure: 'ROLLBACK'
		}
		.promise()

	else
		if status.includes 'IN_PROGRESS'
			throw new Error "Stack is in progress: #{ status }"

		try
			result = await cloudFormation.updateStack {
				...params
			}
			.promise()

		catch error
			if error.message.includes 'No updates are to be performed'
				warn 'Nothing to deploy!'
				return

			throw error

	state = if exists then 'stackUpdateComplete' else 'stackCreateComplete'

	try
		await cloudFormation.waitFor state, { StackName: stack }
			.promise()

	catch error
		if error.stack
			result = await cloudFormation.describeStackEvents { StackName: stack }
				.promise()

			throw new Error stackEventsError result.StackEvents

		throw error
