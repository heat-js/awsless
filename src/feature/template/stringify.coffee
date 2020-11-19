
import Reference from '../../reference'

export default (template) ->
	return JSON.stringify template, (key, value) ->
		if key is 'Region'
			return

		if typeof value is 'object' and value instanceof Reference
			return value.toJSON()

		return value
