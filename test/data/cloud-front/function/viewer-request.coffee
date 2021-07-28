
import handle 		from '@heat/cloud-front-function'
import ForceNonWww 	from '@heat/cloud-front-function/middleware/force-non-www'

export default handle(
	new ForceNonWww
	(app) ->
		response = event.response
		console.log response
		app.output = response
)

# export default (event) ->
# 	response = event.response
# 	console.log response
# 	return response
