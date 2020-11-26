
find = (list) ->
	regions = []
	for name, item of list
		regions.push item.Region

	return regions

filter = (list, defaultRegion, filterRegion) ->
	filtered = {}
	for name, item of list
		region = (
			item.Region or
			( item.Properties and item.Properties.Region ) or
			defaultRegion
		)

		# console.log name, region

		if region is filterRegion
			filtered[ name ] = item

	return filtered

export default (context) ->
	stack			= context.string '@Config.Stack'
	defaultRegion	= context.string '@Config.Region'
	profile			= context.string '@Config.Profile'
	description		= context.string '@Config.Description', ''

	outputs			= context.getOutputs()
	resources		= context.getResources()

	regions = [
		...find outputs
		...find resources
	].filter (i) -> i

	regions	= [ ...new Set [ ...regions, defaultRegion ] ]

	# console.log regions

	return regions.map (region) ->
		return {
			name:	stack
			region
			profile
			template: {
				AWSTemplateFormatVersion: '2010-09-09'
				Description:	description
				Resources:		filter resources, defaultRegion, region
				Outputs:		filter outputs, defaultRegion, region
			}
		}
