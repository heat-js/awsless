
import Client 			from '../client/cloudformation'
import { task, warn }	from '../console'
import stackStatus 		from './stack-status'

findFirstErrorInStackEvents = (events) ->
	currentEvents = []

	for event in events
		currentEvents.unshift event
		if event.ResourceStatus is 'UPDATE_IN_PROGRESS'
			break

	for event in currentEvents
		if event.ResourceStatus.includes 'FAILED'
			return event.ResourceStatusReason

	for event in events
		if event.ResourceStatus.includes 'FAILED'
			return event.ResourceStatusReason

	return 'Unknown error'

export default ({ profile, region, stackName, template, capabilities = [] }) ->

	cloudFormation = Client { profile, region }

	params = {
		StackName: stackName
		TemplateBody: template
		Capabilities: capabilities
		Tags: [ { Key: 'Stack', Value: stackName } ]
	}

	status = await stackStatus { profile, region, stackName }
	if not status
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

	state = if status then 'stackUpdateComplete' else 'stackCreateComplete'

	try
		await cloudFormation.waitFor state, { StackName: stackName }
			.promise()

	catch error
		if error.stack
			result = await cloudFormation.describeStackEvents { StackName: stackName }
				.promise()

			throw new Error findFirstErrorInStackEvents result.StackEvents

		throw error
