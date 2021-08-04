
import handle 			from '@heat/cloud-front-function'
# import ForceNonWww 		from '@heat/cloud-front-function/middleware/force-non-www'
import SecurityHeaders 	from '@heat/cloud-front-function/middleware/security-headers'

headers = {
	'server':						'ColdFusion X8ZZ1'
	'strict-transport-security':	[ 'max-age=63072000', 'preload']
	'x-xss-protection': 			[ '1', 'mode=block' ]
	'x-content-type-options':		'nosniff'
	'x-download-options':			'noopen'
	'x-frame-options': 				'sameorigin'
	'referrer-policy': 				'same-origin'
	'report-to': JSON.stringify {
		'group': 	'default'
		'max_age':	 31536000
		'endpoints': [{
			'url': 'https://jacksclub.report-uri.com/a/d/g'
		}]
		'include_subdomains': true
	}

	'permissions-policy': Object.entries({
		# 'interest-cohort': 	'()'
		'autoplay': 		'(self)'
		'camera': 			'()'
		'encrypted-media':	'()'
		'fullscreen': 		'(self)'
		'geolocation': 		'()'
		'microphone': 		'()'
		'midi': 			'()'
		'payment': 			'()'
	}).map (entry) ->
		return "#{ entry[0] }=#{ entry[1] }"
	.join ', '

	'feature-policy': {
		'autoplay': 		"'self'"
		'camera': 			"'none'"
		'encrypted-media':	"'none'"
		'fullscreen': 		"'self'"
		'geolocation': 		"'none'"
		'microphone': 		"'none'"
		'midi': 			"'none'"
		'payment': 			"'none'"
	}
}

export default handle(
	new SecurityHeaders headers
	(app) ->
		console.log app.input
		app.output = app.input.response
)
