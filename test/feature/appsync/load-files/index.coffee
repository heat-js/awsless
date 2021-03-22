
import loadFiles	from '../../../../src/feature/appsync/load-files'
import path			from 'path'

describe 'Load appsync files', ->

	root = path.join __dirname, '_files'

	it 'should load appsync files correctly', ->
		result = await loadFiles path.join root, 'test1'
		expect result
			.toStrictEqual {
				schema: expect.any String
				resolvers: [{
					id:			'QueryPosts'
					type:		'Query'
					field:		'posts'
					lambda:		'posts__list'
					request:	expect.any String
					response:	expect.any String
				}]
			}

	# it 'should load appsync files correctly', ->
	# 	result = await loadFiles path.join root, 'test1'
	# 	expect result
	# 		.toStrictEqual {
	# 			schema: expect.any String
	# 			resolvers: [{
	# 				type:		'Query'
	# 				field:		'posts'
	# 				lambda:		'posts__list'
	# 				request:	expect.any String
	# 				response:	expect.any String
	# 			}]
	# 		}


	# 	inputFile	= path.join testDir, 'unknown.coffee'
	# 	outputFile	= path.join tempDir, 'unknown.js'

	# 	await expect build inputFile, outputFile
	# 		.rejects.toThrow Error

	# it 'should throw for invalid code', ->
	# 	inputFile	= path.join testDir, 'invalid-code.coffee'
	# 	outputFile	= path.join tempDir, 'invalid-code.js'

	# 	await expect build inputFile, outputFile
	# 		.rejects.toThrow Error

	# it 'should build valid code', ->
	# 	inputFile	= path.join testDir, 'valid-code.coffee'
	# 	outputFile	= path.join tempDir, 'valid-code.js'

	# 	await build inputFile, outputFile

	# 	result = await fs.promises.readFile outputFile
	# 	result = result.toString 'utf-8'

	# 	expect result.indexOf '!function'
	# 		.toBe 0
