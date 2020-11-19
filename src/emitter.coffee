
export default class Emitter

	constructor: ->
		@events = {}
		@keys = []

	on: (eventName, callback) ->
		list = @events[ eventName ]
		if not list
			list = @events[ eventName ] = []

		list.push callback

	once: (key, eventName, callback) ->
		if @keys.includes key
			return

		@keys.push key
		@on eventName, callback

	emit: (eventName, ...props) ->
		list = @events[ eventName ]
		if not list
			return

		for callback in list
			await callback.apply null, props
