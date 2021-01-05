
import load		from '../../../src/feature/template/load'
import path		from 'path'
import fs		from 'fs'

describe 'Template Load', ->

	dir = path.join process.cwd(), 'test/data'

	it 'should load', ->
		result = await load path.join dir, 'aws'
		expect result.Config
			.toBeDefined()

	it 'should throw when directory is empty', ->
		await expect load path.join dir, 'empty'
			.rejects.toThrow "AWS template directory has no template files inside"

	it 'should throw when directory doesn\'t exist', ->
		await expect load path.join dir, 'unknown'
			.rejects.toThrow "AWS template directory doesn't exist"
