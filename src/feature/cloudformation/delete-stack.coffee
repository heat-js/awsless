
import Client 			from '../client/cloudformation'
import { task, warn }	from '../console'
import stackStatus 		from './stack-status'
import stackEventsError from './stack-events-error'

export default ({ profile, region, stack }) ->
	params = { StackName: stack }
	status = await stackStatus { profile, region, stack }
	if not status
		warn 'Stack has already been deleted!'
		return

	if status.includes 'IN_PROGRESS'
		throw new Error "Stack is in progress: #{ status }"

	cloudFormation = Client { profile, region }

	result = await cloudFormation.deleteStack params
		.promise()

	state = if status then 'stackDeleteComplete' else 'stackCreateComplete'

	try
		await cloudFormation.waitFor 'stackDeleteComplete', params
			.promise()

	catch error
		if error.stack
			result = await cloudFormation.describeStackEvents params
				.promise()

			throw new Error stackEventsError result.StackEvents

		throw error
