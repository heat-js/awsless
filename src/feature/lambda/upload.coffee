

import Client				from '../client/s3'
import path					from 'path'
import build				from './build'
import hash 				from '../crypto/hash'
import zip 					from '../fs/zip-file'
import { createReadStream }	from 'fs'
import { task, warn }		from '../console'
import time					from '../performance/time'
import filesize 			from 'filesize'
import chalk				from 'chalk'

# build = (inputFile, outputFile, fast) ->
# 	dir = path.join __dirname, './build'
# 	worker = new Worker '../', { workerData: {num: 5}});

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

export default ({ profile, region, bucket, name, stack, handle }) ->

	root = process.cwd()

	file = handle
	file = file.substr 0, file.lastIndexOf '.'
	file = path.join root, file

	outputPath = path.join root, '.awsless', 'lambda'


	uncompFile	= path.join outputPath, "#{ name }.js"
	compFile	= path.join outputPath, "#{ name }.compressed.js"
	zipFile 	= path.join outputPath, "#{ name }.zip"
	key			= "#{ stack }/#{ name }.zip"
	elapsed 	= time()

	{ fileHash, object } = await task(
		chalk"Checking Lambda: {yellow #{ name }.zip}"
		{ persist: false }
		(->
			await build file, uncompFile, true

			fileHash 	= await hash 'sha1', uncompFile, 'hex'
			fileHash	= fileHash.substr 0, 16
			object		= await getObject { profile, region, bucket, key }
			return { fileHash, object }
		)()
	)

	if object and object.metadata.filehash is fileHash
		warn chalk"{white Unchanged Lambda: {yellow #{ name }.zip} (build: {blue #{ elapsed() }})}"
		return { key, fileHash, zipHash: object.metadata.ziphash, version: object.version }

	{ zipHash, size } = await task(
		chalk"Building Lambda: {yellow #{ name }.zip}"
		{ persist: false }
		(->
			await build file, compFile, false

			size		= await zip compFile, "index.js", zipFile
			zipHash		= await hash 'sha256', zipFile, 'base64'

			return { zipHash, size }
		)()
	)

	# { fileHash, zipHash, size, object } = await task(
	# 	chalk"Building Lambda: {yellow #{ name }.zip}"
	# 	{ persist: false }
	# 	(->
	# 		await build file, jsFile

	# 		size		= await zip jsFile, "index.js", zipFile
	# 		fileHash	= await sha256 jsFile, 'hex'
	# 		fileHash	= fileHash.substr 0, 16
	# 		zipHash		= await sha256 zipFile, 'base64'
	# 		object		= await getObject { profile, region, bucket, key }

	# 		return { fileHash, zipHash, size, object }
	# 	)()
	# )

	# if object and object.metadata.filehash is fileHash
	# 	warn chalk"{white Unchanged Lambda: {yellow #{ name }.zip} (build: {blue #{ elapsed() }}) (size: {blue #{ filesize size }})}"
	# 	return { key, fileHash, zipHash: object.metadata.ziphash, version: object.version }

	s3 = Client { profile, region }

	params = {
		Bucket: 		bucket
		Key:			key
		ACL:			'private'
		Body:			createReadStream zipFile
		StorageClass:	'STANDARD'
		Metadata: {
			filehash:	fileHash
			ziphash:	zipHash
		}
	}

	result = await task(
		chalk"Uploading Lambda: {yellow #{ name }.zip} to S3 (build: {blue #{ elapsed() }}) (size: {blue #{ filesize size }})"
		s3.putObject params
			.promise()
	)

	return { key, fileHash, zipHash, version: result.VersionId }
