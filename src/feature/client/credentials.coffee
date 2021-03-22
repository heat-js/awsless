
import AWS from 'aws-sdk'

export default ({ profile }) ->
	chain = new AWS.CredentialProviderChain()

	if profile
		chain.providers.push new AWS.SharedIniFileCredentials { profile }

	return chain
