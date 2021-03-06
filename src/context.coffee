
import Emitter		from './emitter'
import Reference	from './reference'
import objectPath	from './feature/object-path'

export default class Context

	constructor: ({
		@name
		@singletons	= {}
		@resource	= {}
		@template	= {}
		@outputs	= {}
		@resources	= {}
		@globals	= {}
		@emitter
	}) ->
		@refs = {}

	find: (type) ->
		resources = []
		for Name, resource of @template
			if resource.Type is type
				resources.push {
					Name
					...resource
				}

		return resources

	getResources: ->
		return @resources

	getOutputs: ->
		return @outputs

	setAttribute: (name, attr, value) ->
		@globals[ "attr-#{ name }-#{ attr }" ] = value

		# ref = @ref "attr-#{ name }.#{ attr }"
		# ref.setValue value
		# return @

	getAttribute: (name, attr) ->
		return @globals[ "attr-#{ name }-#{ attr }" ]

	addResource: (name, resource) ->
		@resources[name] = resource

	addOutput: (name, output) ->
		@outputs[name] = output

	ref: (key) ->
		return @refs[ key ] or ( @refs[ key ] = new Reference )

	value: (key, value) ->
		ref = @ref key
		ref.setValue value

	singleton: (key, value) ->
		return @singletons[ key ] or ( @singletons[ key ] = value )

	copy: (name, resource) ->
		return new Context {
			@resources
			@singletons
			@template
			@outputs
			@emitter
			@globals
			name
			resource
		}

	once: (event, callback) ->
		@emitter.once @resource.Type, event, callback

	on: (event, callback) ->
		@emitter.on event, callback

	string:		(paths, defaultValue) -> @property 'string',	paths, defaultValue
	number:		(paths, defaultValue) -> @property 'number',	paths, defaultValue
	boolean:	(paths, defaultValue) -> @property 'boolean',	paths, defaultValue
	array:		(paths, defaultValue) -> @property 'array',		paths, defaultValue
	object:		(paths, defaultValue) -> @property 'object',	paths, defaultValue
	any:		(paths, defaultValue) -> @property undefined,	paths, defaultValue

	property: (type, paths, defaultValue) ->
		return objectPath {
			@template
			@resource
			properties: @resource.Properties
			type
			paths
			defaultValue
		}
