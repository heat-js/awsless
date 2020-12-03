
import Emitter		from './emitter'
import Reference	from './reference'
import objectPath	from './feature/object-path'

export default class Context

	constructor: ({
		@name
		@singletons	= {}
		@resource	= {}
		@properties	= {}
		@template	= {}
		@outputs	= {}
		@resources	= {}
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

	addResource: (name, resource) ->
		@resources[name] = resource

	addOutput: (name, output) ->
		@outputs[name] = output

	ref: (key) ->
		return @refs[ key ] or ( @refs[ key ] = new Reference )

	value: (key, value) ->
		ref = @refs[ key ]
		ref.setValue value

	singleton: (key, value) ->
		return @singletons[ key ] or ( @singletons[ key ] = value )

	copy: (name, resource, properties) ->
		return new Context {
			@resources
			@singletons
			@template
			@outputs
			@emitter
			name
			resource
			properties
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
			@properties
			type
			paths
			defaultValue
		}
