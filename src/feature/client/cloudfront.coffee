
import AWS from 'aws-sdk'

export default ({ profile, region }) ->

	return new AWS.CloudFront {
		apiVersion: '2019-03-26'
		credentials: new AWS.SharedIniFileCredentials { profile }
		region
	}
