
import commonjs		from 'rollup-plugin-commonjs'
import coffee		from 'rollup-plugin-coffee-script'
import nodeResolve	from 'rollup-plugin-node-resolve'
import { terser }	from 'rollup-plugin-terser'
import { rollup }	from 'rollup'
import { warn }		from '../console'

export default (inputFile, outputFile) ->

	extensions = [ '.js', '.coffee' ]
	bundle = await rollup {
		input: inputFile
		external: [ 'aws-sdk' ]
		plugins: [
			coffee()
			nodeResolve { extensions }
			commonjs { extensions }
			terser()
		]
		onwarn: warn
	}

	await bundle.write {
		file: outputFile
		format: 'cjs'
		exports: 'named'
		# compact: true
	}


# import webpack from 'webpack'
# import path from 'path'

# options = {
# 	target: 'node'
# 	node: {
# 		__dirname: false
# 		__filename: false
# 	}
# 	externals: {
# 		'aws-sdk':'aws-sdk'
# 	}
# 	stats: 'minimal'
# 	performance: {
# 		# Turn off size warnings for entry points
# 		hints: false
# 	}
# 	module: {
# 		rules: [
# 			{
# 				loader: 'coffee-loader'
# 				test: /\.coffee$/
# 			}
# 		]
# 	}
# 	resolve: {
# 		extensions: [ '.js', '.jsx', '.coffee' ]
# 	}
# }

# export default (entry, output) ->
# 	return new Promise (resolve, reject) ->
# 		compiler = webpack Object.assign {}, options, {
# 			entry:	entry
# 			mode:	'production'
# 			# optimization: {
# 			# 	minimize: false
# 			# }
# 			output: {
# 				path:		path.dirname output
# 				filename:	path.basename output
# 			}
# 		}

# 		compiler.run (error, stats) ->
# 			if error
# 				reject error
# 				return

# 			resolve stats
