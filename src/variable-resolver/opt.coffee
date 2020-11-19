
import minimist from 'minimist'

opts = minimist process.argv.slice(2)

export default (options) ->
	return options.map (option) =>
		return opts[ option ]
