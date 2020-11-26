#!/usr/bin/env node

import load				from './feature/template/load'
# import parse			from './feature/template/parse'
import resolveResources	from './feature/template/resolve-resources'
import resolveVariables	from './feature/template/resolve-variables'
# import split 			from './feature/template/split'
import deploy			from './feature/template/deploy'
import stringify		from './feature/template/stringify'
import { task }			from './feature/console'

import cf				from './variable-resolver/cf'
import env				from './variable-resolver/env'
import opt				from './variable-resolver/opt'
import VAR				from './variable-resolver/var'
import ssm				from './variable-resolver/ssm'

# import test				from './resource/test'
import output			from './resource/output'
import website			from './resource/website'
import sqsQueue			from './resource/sqs/queue'
import dynamoDBTable	from './resource/dynamodb/table'
import lambdaFunction	from './resource/lambda/function'
import lambdaPolicy		from './resource/lambda/policy'

localResolvers = {
	env
	opt
	var: VAR
}

remoteResolvers = {
	ssm
	cf
}

customResources = {
	# 'Awsless::Test':				test
	'Awsless::Output':				output
	'Awsless::Website':				website
	'Awsless::SQS::Queue':			sqsQueue
	'Awsless::DynamoDB::Table':		dynamoDBTable
	'Awsless::Lambda::Function':	lambdaFunction
	'Awsless::Lambda::Policy':		lambdaPolicy
}

(->
	path = process.cwd() + '/aws'

	template = await task(
		'Loading templates'
		{ persist: false }
		load path
	)

	template = await task(
		'Resolve variables'
		{ persist: false }
		resolveVariables template, localResolvers
	)

	template = await task(
		'Resolve variables'
		{ persist: false }
		resolveVariables template, remoteResolvers
	)

	context = await task(
		'Parsing custom resources'
		{ persist: false }
		resolveResources template, customResources
	)

	# stacks = split context

	# console.log util.inspect templates, {
	# 	depth:	Infinity
	# 	colors: true
	# }

	await deploy context

)()
