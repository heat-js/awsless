
<<<<<<< HEAD
import AWS		from 'aws-sdk'
import cache	from 'function-cache'
# import credentials from '../credentials'
=======
import cache			from 'function-cache'
import CloudFormation	from '../client/cloudformation'
>>>>>>> 5ef81572527fa510c6995c3e77ed08df529e0656

export default cache ({ profile, region }) ->
	cloudFormation = CloudFormation {
		profile
		region
	}

	list	= {}
	params	= {}

	while true
		result = await cloudFormation.listExports params
			.promise()

		for item in result.Exports
			list[ item.Name ] = item.Value

		if result.NextToken
			params.NextToken = result.NextToken
		else
			break

	return list
