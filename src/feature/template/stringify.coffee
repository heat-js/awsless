
import Reference from '../../reference'

export default (template) ->
	return JSON.stringify template, (key, value) ->
		if key is 'Region'
			return

		if key is 'Fn::GetAtt' and typeof value is 'string'
			parts = value.split '.'
			return [
				parts.shift()
				parts.join '.'
			]

		if typeof value is 'object' and value instanceof Reference
			return value.toJSON()

		return value
