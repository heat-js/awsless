
# makeRegex = ->
# 	return /\$\{ *([a-z]+)\:([a-z0-9-_/\.:]+) *\}/gmi

variablesItem = (variableResolvers, variables, key, value, object) ->
	switch typeof value
		when 'string'
			regex = /\$\{ *([a-z]+)\:([a-z0-9-_/\.:]+) *\}/gmi
			while matches = regex.exec value
				[ match, type, path ] = matches

				if not variableResolvers[type]
					continue

				variables.push { key, object, match, type, path }

		when 'object', 'array'
			findVariables variableResolvers, variables, value

findVariables = (variableResolvers, variables, object) ->
	switch typeof object
		when 'array'
			for value, key in object
				variablesItem variableResolvers, variables, key, value, object
		when 'object'
			for key, value of object
				variablesItem variableResolvers, variables, key, value, object

condenseReplacements = (replacements) ->
	limit = 10
	while limit--
		replaced = false
		for original, replacement of replacements
			value = replacements[ replacement ]
			if typeof value isnt 'undefined'
				replacements[ original ] = value
				replaced = true

		if not replaced
			break

	return replacements

getVariableReplacements = (variableResolvers, variables, template) ->
	replacements = {}
	for type, resolver of variableResolvers
		list = variables.filter (entry) ->
			return type is entry.type

		if list.length
			matches = {}
			for item in list
				matches[ item.path ] = item.match

			paths	= Object.keys matches
			matches = Object.values matches
			values	= await resolver paths, template

			for replacement, index in values
				match = matches[ index ]
				replacements[ match ] = replacement

	return replacements

export default (template, variableResolvers = {}) ->
	template = JSON.parse JSON.stringify template
	variables = []
	findVariables variableResolvers, variables, template

	replacements = await getVariableReplacements variableResolvers, variables, template
	replacements = condenseReplacements replacements

	errors = []

	for entry, index in variables
		value		= entry.object[ entry.key ]
		replacement = replacements[ entry.match ]

		if typeof replacement isnt 'undefined'
			value = value.replace entry.match, replacement
			entry.object[ entry.key ] = value
		else
			errors.push entry.match

	if errors.length
		throw new Error "Unable to resolve variables: #{ errors.join ', ' }"

	return template
