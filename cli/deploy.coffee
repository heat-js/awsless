#!/usr/bin/env node

import load				from '../src/feature/template/load'
import parse			from '../src/feature/template/parse'
import resolveVariables	from '../src/feature/template/resolve-variables'
import deploy			from '../src/feature/template/deploy'
import stringify		from '../src/feature/template/stringify'
import { task }			from '../src/feature/console'

import cf				from '../src/variable-resolver/cf'
import env				from '../src/variable-resolver/env'
import opt				from '../src/variable-resolver/opt'
import VAR				from '../src/variable-resolver/var'
import ssm				from '../src/variable-resolver/ssm'

import test				from '../src/resource/test'
import output			from '../src/resource/output'
import website			from '../src/resource/website'
import sqsQueue			from '../src/resource/sqs/queue'
import dynamoDBTable	from '../src/resource/dynamodb/table'
import lambdaFunction	from '../src/resource/lambda/function'
import lambdaPolicy		from '../src/resource/lambda/policy'

resolvers = {
	cf
	env
	opt
	var: VAR
	ssm
}

customResources = {
	'Custom::Test':					test
	'Custom::Output':				output
	'Custom::Website':				website
	'Custom::SQS::Queue':			sqsQueue
	'Custom::DynamoDB::Table':		dynamoDBTable
	'Custom::Lambda::Function':		lambdaFunction
	'Custom::Lambda::Policy':		lambdaPolicy
}

(->
	path = process.cwd() + '/aws'

	{ context, template } = await task(
		'Parsing templates'
		(->
			template	= await load path
			template 	= await resolveVariables template, resolvers

			return parse template, customResources
		)()
	)

	# console.log util.inspect template, {
	# 	depth:	Infinity
	# 	colors: true
	# }

	await deploy { context, template }

)()
