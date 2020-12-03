
# import builtins		from 'builtin-modules'
# import commonjs		from '@rollup/plugin-commonjs'
# import coffee		from 'rollup-plugin-coffee-script'
# import nodeResolve	from '@rollup/plugin-node-resolve'
# import json 		from '@rollup/plugin-json'
# import { terser }	from 'rollup-plugin-terser'
# import { rollup }	from 'rollup'
# import { warn }		from '../console'

# export default (inputFile, outputFile) ->

# 	extensions = [ '.js', '.coffee' ]
# 	bundle = await rollup {
# 		input: inputFile
# 		external: [ 'aws-sdk', ...builtins ]
# 		plugins: [
# 			json()
# 			coffee()
# 			nodeResolve { extensions }
# 			commonjs { extensions, sourceMap: false }
# 			terser()
# 		]
# 		onwarn: (warning) ->
# 			switch warning.code
# 				when 'CIRCULAR_DEPENDENCY', 'THIS_IS_UNDEFINED', 'SOURCEMAP_ERROR'
# 					return

# 			warn warning
# 	}

# 	await bundle.write {
# 		file: outputFile
# 		format: 'cjs'
# 		exports: 'named'
# 		sourcemap: false
# 		# sourcemap: false
# 		# compact: true
# 	}


import nodeExternals	from 'webpack-node-externals'
import TerserPlugin		from 'terser-webpack-plugin'
import webpack			from 'webpack'
import path				from 'path'

# import nodeLoader		from 'node-loader'
# import coffeeLoader		from 'coffee-loader'

webpackOptions = {
	target: 'node'
	context: process.cwd()
	devtool: false
	node: {
		__dirname: false
		__filename: false
	}
	# externals: [ nodeExternals(), 'aws-sdk' ]
	stats: 'minimal'
	performance: {
		# Turn off size warnings for entry points
		hints: false
	}
	module: {
		rules: [
			{
				loader: require.resolve 'coffee-loader'
				test: /\.coffee$/
			}
			{
				loader: require.resolve 'node-loader'
				test: /\.node$/
			}
		]
	}
	resolve: {
		extensions: [ '.js', '.jsx', '.coffee' ]
	}
}

export default (inputFile, outputFile, options) ->

	options = {
		minimize: true
		externals: []
		...options
	}

	return new Promise (resolve, reject) ->
		compiler = webpack Object.assign {}, webpackOptions, {
			entry:	inputFile
			mode:	if options.minimize then 'production' else 'development'
			optimization: {
				minimize: options.minimize
				minimizer: [
					new TerserPlugin {
						parallel: true
						terserOptions: {
							output: {
								comments: false
							}
						}
					}
				]
			}
			externals: [
				nodeExternals()
				'aws-sdk'
				...options.externals
			]
			# optimization: {
			# 	minimize: false
			# }
			output: {
				path:			path.dirname outputFile
				filename:		path.basename outputFile
				libraryTarget:	'commonjs'
			}
		}

		compiler.run (error, stats) ->
			if error
				reject error
				return

			data = stats.toJson()
			if data.errors.length
				info = data.errors[0]
				error = new Error """
					#{ info.message }
					File: #{ info.moduleName }
				"""

				error.file		= info.moduleName
				error.details	= info.details

				# console.error data.errors

				reject error
				return

			resolve stats
