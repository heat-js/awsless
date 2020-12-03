

import resource	from '../../feature/resource'

export addPolicy = (ctx, name, statements) ->
	policies = ctx.singleton 'lambda-policies', {}
	policies[name] = [
		...( policies[name] or [] )
		...toArray statements
	]

uniqueArray = (array) ->
	array = array.map (item)->
		return JSON.stringify item

	return [ ...new Set array ].map (item) ->
		return JSON.parse item

toArray = (array) ->
	if Array.isArray array
		return array

	return [ array ]

statementKey = (statement) ->
	return [
		...toArray statement.Effect
		...toArray statement.Action
	].sort().join '-'

condenseStatements = (statements) ->
	list = {}
	for statement in statements
		key = statementKey statement
		entry = list[ key ]
		if not entry
			list[ key ] = {
				Effect:		statement.Effect
				Action:		statement.Action
				Resource:	toArray statement.Resource
			}
		else
			Object.assign entry, {
				Resource: [
					...entry.Resource
					...toArray statement.Resource
				]
			}

	return Object.values(list).map (entry) ->
		return { ...entry, Resource: uniqueArray entry.Resource }

export default resource (ctx) ->

	addPolicy ctx, ctx.name, ctx.any '#Properties'

	ctx.once 'before-stringify-template', ->

		list = ctx.singleton 'lambda-policies', {}

		if not Object.keys(list).length
			return

		policies = []
		for PolicyName, Statement of list
			policies.push {
				PolicyName
				PolicyDocument: {
					Version: '2012-10-17'
					Statement: condenseStatements Statement
				}
			}

		Stack	= ctx.string '@Config.Stack'
		Region	= ctx.string '@Config.Region'

		ctx.addResource "LambdaPolicyIamRole", {
			Type: 'AWS::IAM::Role'
			Region
			Properties: {
				Path: '/'
				RoleName: "#{ Stack }-#{ Region }-lambda-role"
				AssumeRolePolicyDocument: {
					Version: '2012-10-17'
					Statement: [ {
						Effect: 'Allow'
						Principal: {
							Service: [ 'lambda.amazonaws.com' ]
						}
						Action: [ 'sts:AssumeRole' ]
					} ]
				}
				Policies: policies
			}
		}
