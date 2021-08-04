
import handle 			from '@heat/cloud-front-function'


export default handle(
	(app = {}) ->
		app.output = app.input.response
)
