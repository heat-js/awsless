
export default (callback) ->
	return (context, name, properties) ->
		# console.log context, name, properties
		callback context.copy(
			name
			properties
		)
