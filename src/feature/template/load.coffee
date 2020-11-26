
import fs							from 'fs'
import path 						from 'path'
import YAML							from 'js-yaml'
import { CLOUDFORMATION_SCHEMA }	from 'js-yaml-cloudformation-schema'
import isDirectory					from '../fs/is-directory'

recursiveReadDir = (directory) ->
	files = await fs.promises.readdir directory

	return await Promise.all(
		files.map (file) =>
			file = path.join directory, file
			if await isDirectory file
				return @recursiveReadDir file

			return file

		.flat()
	)

export default (directory) ->
	try
		files = await recursiveReadDir directory
	catch error
		if error.code is 'ENOENT'
			throw new Error "AWS template directory doesn't exist '#{ directory }'"

		throw error

	files = files.filter (file) ->
		extension = path
			.extname file
			.toLowerCase()

		return [ '.yml', '.yaml' ].includes extension

	if files.length is 0
		throw new Error "AWS template directory has not template files inside."

	files = await Promise.all files.map (file) ->
		data = await fs.promises.readFile file
		return YAML.load data, {
			schema: CLOUDFORMATION_SCHEMA
		}

	return Object.assign {}, ...files
