
import AWS from 'aws-sdk'
# import credentials from '../credentials'

export default ({ profile, region }) ->

	return new AWS.CloudFront {
		apiVersion: '2019-03-26'
		credentials: new AWS.SharedIniFileCredentials { profile }
		region
	}
