
import fetchSsm	from '../feature/fetch/ssm'

export default (paths, root) ->

	parameters = await fetchSsm {
		paths
		profile:	root.Config.Profile
		region:		root.Config.Region
	}

	return paths.map (path) ->
		return parameters[ path ]

# export default (paths, root) ->
# 	profile			= root.Config.Profile
# 	defaultRegion 	= root.Config.Region

# 	list = {}

# 	for path, index in paths
# 		data = path.split ':'
# 		if data.length is 1
# 			path	= data[0]
# 			region	= defaultRegion
# 		else
# 			path	= data[1]
# 			region	= data[0]

# 		if entries = list[ region ]
# 			entries.push path
# 		else
# 			list[ region ] = [ path ]

# 	results = {}
# 	for region, paths of list
# 		parameters = await fetchSsm { paths, profile, region }
# 		return parameters[ path ]


# 	paths = paths.map (path) ->
# 		data = path.split ':'
# 		if data.length is 1
# 			return {
# 				path:	data[0]
# 				region
# 			}

# 		return {
# 			path:	data[1]
# 			region: data[0]
# 		}

# 	return Promise.all paths.map ({ path, region }) ->
# 		parameters = await fetchSsm { paths, profile, region }
# 		return parameters[ path ]


# 	parameters = await fetchSsm {
# 		paths
# 		profile:	root.Config.Profile
# 		region:		root.Config.Region
# 	}

# 	return paths.map (path) ->
# 		return parameters[ path ]

# import fetchExports	from '../feature/fetch/exports'

# export default (names, root) ->
# 	profile = root.Config.Profile
# 	region 	= root.Config.Region

# 	names = names.map (name) ->
# 		data = name.split ':'
# 		if data.length is 1
# 			return {
# 				name:	data[0]
# 				region
# 			}

# 		return {
# 			name:	data[1]
# 			region: data[0]
# 		}

# 	return Promise.all names.map ({ name, region }) ->
# 		data = await fetchExports { profile, region }
# 		return data[ name ]
