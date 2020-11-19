
import fetchSsm	from '../feature/fetch/ssm'

export default (paths, root) ->
	parameters = await fetchSsm {
		paths
		profile:	root.Config.Profile
		region:		root.Config.Region
	}

	return paths.map (path) ->
		return parameters[ path ]
