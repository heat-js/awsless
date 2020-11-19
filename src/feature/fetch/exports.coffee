
import AWS		from 'aws-sdk'
import cache	from 'function-cache'

export default cache ({ profile, region }) ->
	cloudFormation = new AWS.CloudFormation {
		apiVersion: '2010-05-15'
		credentials: new AWS.SharedIniFileCredentials { profile }
		region
	}

	list	= {}
	params	= {}

	while true
		result = await cloudFormation.listExports params
			.promise()

		# console.log result, profile, region

		for item in result.Exports
			list[ item.Name ] = item.Value

		if result.NextToken
			params.NextToken = result.NextToken
		else
			break

	return list
