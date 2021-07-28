
import handle from '@heat/lambda'

export default handle(
	(app) ->
		response = event.response
		console.log response
		app.output = response
)

# export default (event) ->
# 	response = event.response
# 	console.log response
# 	return response
