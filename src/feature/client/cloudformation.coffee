
import AWS from 'aws-sdk'

export default ({ profile, region }) ->

	return new AWS.CloudFormation {
		apiVersion: '2010-05-15'
		credentials: new AWS.SharedIniFileCredentials { profile }
		region
	}
