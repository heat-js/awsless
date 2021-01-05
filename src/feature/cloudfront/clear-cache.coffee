
import AWS from 'aws-sdk'
# import credentials from '../credentials'

export default ({ profile, region, distributionId }) ->

	cloudfront = new AWS.CloudFront {
		apiVersion: '2019-03-26'
		credentials: new AWS.SharedIniFileCredentials { profile }
		region
	}

	await cloudfront.createInvalidation {
		DistributionId: distributionId
		InvalidationBatch: {
			CallerReference: String Date.now()
			Paths: {
				Quantity: 1
				Items: [ '/*' ]
			}
		}
	}
	.promise()
