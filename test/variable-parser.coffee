
import VariableParser	from '../src/variable-parser'
import Env				from '../src/resolver/env'
import Opt				from '../src/resolver/opt'
import Var				from '../src/resolver/var'
import Ssm				from '../src/resolver/ssm'

jest.setTimeout 60 * 1000

describe 'Cloud Formation', ->
	resolvers = {
		'env': new Env
		'opt': new Opt
		'var': new Var
		'ssm': new Ssm
	}

	it 'parse', ->
		variableParser = new VariableParser resolvers

		await variableParser.parse {
			Config: {
				Name: 'Name'
			}

			test: '${ cf:1:2 }'
			test1: '${ var:Config.Name }'
			test2: 'test${aws:/1}asdsad'
			multi: 'test${aws:/1}asdsad${cf:2}'
			deep: {
				test: '${aws:/3}'
			}
			deeper: [
				'lol'
				{ test: 'deeper-${aws:/4}' }
			]
		}
