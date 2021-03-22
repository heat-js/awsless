
import cf						from './variable-resolver/cf'
import env						from './variable-resolver/env'
import opt						from './variable-resolver/opt'
import Var						from './variable-resolver/var'
import ssm						from './variable-resolver/ssm'
import attr						from './variable-resolver/attr'
import When						from './variable-resolver/when'

import output					from './resource/output'
import website					from './resource/website'
import appsyncApi				from './resource/appsync/api'
import snsTopic					from './resource/sns/topic'
import sqsQueue					from './resource/sqs/queue'
import dynamoDBTable			from './resource/dynamodb/table'
import lambdaFunction			from './resource/lambda/function'
import lambdaPolicy				from './resource/lambda/policy'
import lambdaLayer				from './resource/lambda/layer'
import lambdaEventInvokeConfig	from './resource/lambda/event-invoke-config'

export localResolvers = {
	env
	opt
	var: Var
	attr
}

export remoteResolvers = {
	ssm
	cf
}

export logicalResolvers = {
	when: When
}

export resources = {
	'Awsless::Output':						output
	'Awsless::Website':						website
	'Awsless::Appsync::Api':				appsyncApi
	'Awsless::SNS::Topic':					snsTopic
	'Awsless::SQS::Queue':					sqsQueue
	'Awsless::DynamoDB::Table':				dynamoDBTable
	'Awsless::Lambda::Function':			lambdaFunction
	'Awsless::Lambda::Policy':				lambdaPolicy
	'Awsless::Lambda::Layer':				lambdaLayer
	'Awsless::Lambda::AsyncConfig':			lambdaEventInvokeConfig
}
