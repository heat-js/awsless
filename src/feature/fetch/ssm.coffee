
import AWS		from 'aws-sdk'
import store	from 'aws-param-store'
import cache	from 'function-cache'
import credentials from '../client/credentials'

formatPaths = (paths) ->
	return paths.map (path) ->
		if path[0] is '/'
			return path

		return "/#{ path }"

export default cache ({ paths, profile, region }) ->
	formattedPaths = formatPaths paths
	result = await store.getParameters formattedPaths, {
		credentials: new AWS.SharedIniFileCredentials { profile }
		region
	}

	parameters = {}
	for formattedPath, index in formattedPaths
		parameter = result.Parameters.find (item) ->
			return item.Name is formattedPath

		parameters[ paths[index] ] = parameter.Value

	return parameters
