
import AWS from 'aws-sdk'
# import credentials from './credentials'

export default ({ profile, region }) ->

	return new AWS.S3 {
		apiVersion: '2006-03-01'
		credentials: new AWS.SharedIniFileCredentials { profile }
		region
	}
