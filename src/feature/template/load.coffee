
import fs							from 'fs'
import path 						from 'path'
import YAML							from 'js-yaml'
import { CLOUDFORMATION_SCHEMA }	from 'js-yaml-cloudformation-schema'
import isDirectory					from '../is-directory'

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
	files = await recursiveReadDir directory
	files = files.filter (file) ->
		extension = path
			.extname file
			.toLowerCase()

		return [ '.yml', '.yaml' ].includes extension

	files = await Promise.all files.map (file) ->
		data = await fs.promises.readFile file
		return YAML.load data, {
			schema: CLOUDFORMATION_SCHEMA
		}

	return Object.assign {}, ...files
