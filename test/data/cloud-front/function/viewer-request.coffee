
import handle 			from '@heat/cloud-front-function'
# import ForceNonWww 		from '@heat/cloud-front-function/middleware/force-non-www'
import SecurityHeaders 	from '@heat/cloud-front-function/middleware/security-headers'

headers = {
	'server':						'ColdFusion X8ZZ1'
	'strict-transport-security':	[ 'max-age=63072000', 'preload' ]
	'x-content-type-options':		'nosniff'
	'feature-policy': {
		'autoplay': 		"'self'"
		'camera': 			"'none'"
		'encrypted-media':	"'none'"
		'fullscreen': 		"'self'"
	}
}

export default handle(
	new SecurityHeaders headers
	(app) ->
		console.log app.input
		app.output = app.input.response
)
