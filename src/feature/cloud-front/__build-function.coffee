
import path			from 'path'
import fs			from 'fs'
import { run }		from '../terminal/task'
import { spawn, Thread, Worker } from 'threads'


build = (input, output, options) ->
	worker = await spawn new Worker './build'

	try
		result = await worker.build input, output, options

	catch error
		throw error

	finally
		await Thread.terminate worker

	return result

export default ({ name, handle }) ->

	root = process.cwd()

	file = handle
	# file = file.substr 0, file.lastIndexOf '.'
	file = path.join root, file

	outputPath	= path.join root, '.awsless', 'cf-functions', name
	compPath	= path.join outputPath, 'compressed'
	compFile	= path.join compPath,	"#{ name }.js"

	return run (task) ->
		task.setPrefix 'CloudFront Functions'

		task.setContent 'Building...'

		await build file, compFile, {
			minimize: false
		}

		code = fs.readFileSync compFile, 'utf8'

		return code
