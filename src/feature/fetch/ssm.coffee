
import AWS		from 'aws-sdk'
import store	from 'aws-param-store'
import cache	from 'function-cache'

formatPaths = (paths) ->
	return paths.map (path) ->
		if path[0] is '/'
			return path

		return "/#{ path }"

export default cache ({ paths, profile, region }) ->
	result = await store.getParameters formatPaths(paths), {
		credentials: new AWS.SharedIniFileCredentials { profile }
		region
	}

	parameters = {}
	for item, index in result.Parameters
		parameters[ paths[index] ] = item.Value

	return parameters
