
import resolveVariables	from '../../../src/feature/template/resolve-variables'
import Var				from '../../../src/variable-resolver/var'

describe 'Resolve Variables', ->
	resolvers = {
		'var': Var
	}

	it 'should resolve simple variables', ->
		template = {
			foo: 'bar'
			key: '${ var:foo }'
		}

		result = await resolveVariables template, resolvers
		expect result
			.toStrictEqual {
				foo: 'bar'
				key: 'bar'
			}

	it 'should resolve variables in text', ->
		template = {
			foo: 'bar'
			1: 'prefix-${ var:foo }'
			2: '${ var:foo }-postfix'
			3: 'prefix-${ var:foo }-postfix'
		}

		result = await resolveVariables template, resolvers
		expect result
			.toStrictEqual {
				foo: 'bar'
				1: 'prefix-bar'
				2: 'bar-postfix'
				3: 'prefix-bar-postfix'
			}

	it 'should resolve variables in an array', ->
		template = {
			var1: 1
			var2: 2
			array: [
				'bar'
				'foo'
				'${ var:array.0 }'
				'${ var:array.1 }'
				{ key: '${ var:var2 }' }
				{ key: '${ var:var1 }' }
			]
		}

		result = await resolveVariables template, resolvers
		expect result
			.toStrictEqual {
				var1: 1
				var2: 2
				array: [
					'bar'
					'foo'
					'bar'
					'foo'
					{ key: '2' }
					{ key: '1' }
				]
			}

	it 'should resolve multiple variables in single line', ->
		template = {
			var1: 'bar'
			var2: 'foo'
			test: 'Hallo ${ var:var1 } ${ var:var2 } ${ var:var1 } World'
		}

		result = await resolveVariables template, resolvers
		expect result
			.toStrictEqual {
				var1: 'bar'
				var2: 'foo'
				test: 'Hallo bar foo bar World'
			}

	it 'should resolve deep paths', ->
		template = {
			multi:
				test: '${ var:multi.level.foo }'
				level:
					foo: 'bar'
		}

		result = await resolveVariables template, resolvers
		expect result
			.toStrictEqual {
				multi:
					test: 'bar'
					level:
						foo: 'bar'
			}

	it 'should resolve recursive variables', ->
		template = {
			one: 'foo'
			three: '${ var:two }'
			two: '${ var:one }'
			four: '${ var:three }'
		}

		result = await resolveVariables template, resolvers
		expect result
			.toStrictEqual {
				one: 'foo'
				two: 'foo'
				three: 'foo'
				four: 'foo'
			}

	it 'should not resolve unknown resolvers or paths', ->
		template = {
			unknownPath: '${ var:abc }'
			unknownResolver: '${ unk:abc }'
		}

		await expect resolveVariables template, resolvers
			.rejects.toThrow 'Unable to resolve variables'
