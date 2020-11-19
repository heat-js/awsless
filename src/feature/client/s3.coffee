
import AWS from 'aws-sdk'

export default ({ profile, region }) ->

	return new AWS.S3 {
		apiVersion: '2006-03-01'
		credentials: new AWS.SharedIniFileCredentials { profile }
		region
	}
