
import AWS from 'aws-sdk'

export default ({ profile }) ->

	return new AWS.SharedIniFileCredentials { profile }
