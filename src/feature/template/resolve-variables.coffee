
# makeRegex = ->
# 	return /\$\{ *([a-z]+)\:([a-z0-9-_/\.:]+) *\}/gmi

findVariables = (variables, object) ->
	if typeof object isnt 'object'
		return

	for key, value of object
		switch typeof value
			when 'string'
				regex = /\$\{ *([a-z]+)\:([a-z0-9-_/\.:]+) *\}/gmi
				while matches = regex.exec value
					variables.push {
						key
						object
						match:		matches[0]
						type:		matches[1]
						path:		matches[2]
					}

			when 'object'
				findVariables variables, value

			when 'array'
				for item in value
					findVariables variables, item

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
	findVariables variables, template

	replacements = await getVariableReplacements variableResolvers, variables, template
	replacements = condenseReplacements replacements

	for entry, index in variables
		value		= entry.object[ entry.key ]
		replacement = replacements[ entry.match ]

		if typeof replacement isnt 'undefined'
			value = value.replace entry.match, replacement
			entry.object[ entry.key ] = value

	return template
