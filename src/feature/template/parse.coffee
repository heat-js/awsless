
import YAML							from 'js-yaml'
import { cloudformationTags }		from 'js-yaml-cloudformation-schema'
import customTypes					from './custom-yaml-types'

schema = YAML.Schema.create [
	...cloudformationTags
	...customTypes
]

export default (data) ->
	return YAML.load data, { schema }
