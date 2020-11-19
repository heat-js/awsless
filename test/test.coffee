
import TemplateParser	from '../src/template-parser'
import VariableParser	from '../src/variable-parser'
import Deployer			from '../src/deployer'

import Env				from '../src/resolver/env'
import Opt				from '../src/resolver/opt'
import Var				from '../src/resolver/var'
import Ssm				from '../src/resolver/ssm'

import Website			from '../src/template/website'
import SqsQueue			from '../src/template/sqs-queue'
import DynamoDBTable	from '../src/template/dynamodb-table'
import Output			from '../src/template/output'
# import LambdaFunction	from '../src/template/lambda-function'

import util 			from 'util'

jest.setTimeout 60 * 1000

describe 'Cloud Formation', ->
	resolvers = {
		'env': new Env
		'opt': new Opt
		'var': new Var
		'ssm': new Ssm
	}

	templates = {
		'Custom::Website':			Website
		'Custom::SQS::Queue':		SqsQueue
		'Custom::DynamoDB::Table':	DynamoDBTable
		'Custom::Output':			Output

		# 'Custom::Lambda::Function':	LambdaFunction
	}

	it 'parse', ->
		# variableParser = new VariableParser resolvers
		# await variableParser.parse {
		# 	Config: {
		# 		Name: 'Name'
		# 	}

		# 	test: 'test'
		# 	test1: '${ var:Config.Name }'
		# 	test2: 'test${aws:/1}asdsad'
		# 	multi: 'test${aws:/1}asdsad${cf:2}'
		# 	deep: {
		# 		test: '${aws:/3}'
		# 	}
		# 	deeper: [
		# 		'lol'
		# 		{ test: 'deeper-${aws:/4}' }
		# 	]
		# }

		variableParser	= new VariableParser resolvers
		templateParser	= new TemplateParser templates, variableParser
		deployer		= new Deployer templates, templateParser

		await deployer.deploy process.cwd() + '/aws'

		# { templates, document }		= await parser.parse process.cwd() + '/aws'

		# console.log JSON.stringify formation
		# console.log formation.Resources.ContestProgressTable.Properties

		# console.log formation.Resources.Website_S3Bucket.Properties
		# console.log formation.Resources.Website_Route53Record.Properties
		# console.log formation.Resources.Website_CloudFrontDistribution.Properties
		# # console.log formation.Resources
		# console.log formation.Outputs

		# console.log templates
		# console.log util.inspect document, false, null, true


		return
