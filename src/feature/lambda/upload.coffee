

import Client				from '../client/s3'
import path					from 'path'
# import build				from './build'
import createHash 			from '../crypto/hash-file'
import zip 					from '../fs/zip-files'
import { createReadStream }	from 'fs'
# import { task, warn }		from '../console'
import { run }				from '../terminal/task'
import time					from '../performance/time'
import filesize 			from 'filesize'
import chalk				from 'chalk'
import createChecksum		from 'hash-then'
# import Worker				from 'jest-worker'
import { spawn, Thread, Worker } from "threads"


build = (input, output, options) ->
	worker = await spawn new Worker './build'

	try
		result = await worker.build input, output, options

	catch error
		throw error

	finally
		await Thread.terminate worker

	return result

# worker = new Worker require.resolve './build.js'

# const myWorker = new JestWorker(require.resolve('./Worker'), {
#     exposedMethods: ['foo', 'bar', 'getWorkerId'],
#     numWorkers: 4,
#   });

#   console.log(await myWorker.foo('Alice')); // "Hello from foo: Alice"
#   console.log(await myWorker.bar('Bob')); // "Hello from bar: Bob"
#   console.log(await myWorker.getWorkerId()); // "3" ->

# build = (inputFile, outputFile, options) ->
# 	new Worker
# 	# dir = path.join __dirname, './build'
# 	# worker = new Worker '../', { workerData: {num: 5}});

getObject = ({ region, profile, bucket, key }) ->

	s3 = Client { profile, region }

	try
		result = await s3.headObject {
			Bucket: bucket
			Key:	key
		}
		.promise()

	catch error
		if error.code is 'NotFound'
			return

		throw error

	return {
		metadata:	result.Metadata
		version:	result.VersionId
	}

export default ({ profile, region, bucket, name, stack, handle, externals = [], files = {} }) ->

	root = process.cwd()

	file = handle
	file = file.substr 0, file.lastIndexOf '.'
	file = path.join root, file

	outputPath		= path.join root, '.awsless', 'lambda', name
	uncompPath		= path.join outputPath, 'uncompressed'
	compPath		= path.join outputPath, 'compressed'

	uncompFile		= path.join uncompPath, 'index.js'
	compFile		= path.join compPath,	'index.js'
	uncompZipFile	= path.join uncompPath, 'index.zip'
	zipFile 		= path.join compPath,	'index.zip'
	key				= "#{ stack }/#{ name }.zip"
	elapsed 		= time()

	return run (task) ->
		task.setPrefix 'Lambda'
		task.setName "#{ name }.zip"
		task.setContent 'Checking...'

		await build file, uncompFile, {
			minimize: false
			externals
		}

		object		= await getObject { profile, region, bucket, key }
		checksum	= await createChecksum uncompPath
		checksum 	= checksum.substr 0, 16

		if object and object.metadata.checksum is checksum
			task.warning()
			task.setContent 'Unchanged'
			task.addMetadata 'Time', elapsed()

			return { key, checksum, hash: object.metadata.hash, version: object.version }

		task.setContent 'Building...'

		await build file, compFile, {
			minimize: true
			externals
		}

		size = await zip compPath, zipFile
		hash = await createHash 'sha256', zipFile, 'base64'

		s3 = Client { profile, region }

		task.setContent 'Uploading...'
		task.addMetadata 'Size', filesize size

		result = await s3.putObject {
			Bucket: 		bucket
			Key:			key
			ACL:			'private'
			Body:			createReadStream zipFile
			StorageClass:	'STANDARD'
			Metadata: {
				checksum
				hash
			}
		}
		.promise()

		task.setContent 'Uploaded to S3'
		task.addMetadata 'Time', elapsed()

		return { key, checksum, hash, version: result.VersionId }



	# { checksum, object } = await task(
	# 	chalk"Checking Lambda: {yellow #{ name }.zip}"
	# 	{ persist: false }
	# 	(->
	# 		await build file, uncompFile, {
	# 			minimize: false
	# 			externals
	# 		}

	# 		# size		= await zip uncompFile, "index.js", uncompZipFile, files
	# 		# size 		= await zip uncompPath, uncompZipFile, { minimize: false }
	# 		# fileHash 	= await hash 'sha1', uncompZipFile, 'hex'
	# 		# fileHash	= fileHash.substr 0, 16

	# 		checksum	= await createChecksum uncompPath
	# 		checksum 	= checksum.substr 0, 16

	# 		object		= await getObject { profile, region, bucket, key }

	# 		return { checksum, object }
	# 	)()
	# )

	# if object and object.metadata.checksum is checksum
	# 	warn chalk"{white Unchanged Lambda: {yellow #{ name }.zip} (build: {blue #{ elapsed() }})}"
	# 	return { key, checksum, hash: object.metadata.hash, version: object.version }

	# { hash, size } = await task(
	# 	chalk"Building Lambda: {yellow #{ name }.zip}"
	# 	{ persist: false }
	# 	(->
	# 		await build file, compFile, {
	# 			minimize: true
	# 			externals
	# 		}

	# 		size 		= await zip compPath, zipFile
	# 		# size		= await zip compFile, "index.js", zipFile, files
	# 		hash		= await createHash 'sha256', zipFile, 'base64'

	# 		return { hash, size }
	# 	)()
	# )

	# # { fileHash, zipHash, size, object } = await task(
	# # 	chalk"Building Lambda: {yellow #{ name }.zip}"
	# # 	{ persist: false }
	# # 	(->
	# # 		await build file, jsFile

	# # 		size		= await zip jsFile, "index.js", zipFile
	# # 		fileHash	= await sha256 jsFile, 'hex'
	# # 		fileHash	= fileHash.substr 0, 16
	# # 		zipHash		= await sha256 zipFile, 'base64'
	# # 		object		= await getObject { profile, region, bucket, key }

	# # 		return { fileHash, zipHash, size, object }
	# # 	)()
	# # )

	# # if object and object.metadata.filehash is fileHash
	# # 	warn chalk"{white Unchanged Lambda: {yellow #{ name }.zip} (build: {blue #{ elapsed() }}) (size: {blue #{ filesize size }})}"
	# # 	return { key, fileHash, zipHash: object.metadata.ziphash, version: object.version }

	# s3 = Client { profile, region }

	# params = {
	# 	Bucket: 		bucket
	# 	Key:			key
	# 	ACL:			'private'
	# 	Body:			createReadStream zipFile
	# 	StorageClass:	'STANDARD'
	# 	Metadata: {
	# 		checksum
	# 		hash
	# 	}
	# }

	# result = await task(
	# 	chalk"Uploading Lambda: {yellow #{ name }.zip} to S3 (build: {blue #{ elapsed() }}) (size: {blue #{ filesize size }})"
	# 	s3.putObject params
	# 		.promise()
	# )

	# return { key, checksum, hash, version: result.VersionId }
