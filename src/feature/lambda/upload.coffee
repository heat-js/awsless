

import Client				from '../client/s3'
import path					from 'path'
import build				from './build'
import sha256 				from '../crypto/sha256'
import zip 					from '../fs/zip-file'
import { createReadStream }	from 'fs'
import { task, warn }		from '../console'
import filesize 			from 'filesize'
import chalk				from 'chalk'

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

	outputPath = path.join root, '.build', 'lambda'

	jsFile	= path.join outputPath, "#{ name }.js"
	zipFile = path.join outputPath, "#{ name }.zip"

	{ key, fileHash, zipHash, size, object } = await task(
		chalk"Building Lambda: {yellow #{ name }.zip}"
		{ persist: false }
		(->
			await build file, jsFile

			size		= await zip jsFile, "index.js", zipFile
			fileHash	= await sha256 jsFile, 'hex'
			fileHash	= fileHash.substr 0, 16
			zipHash		= await sha256 zipFile, 'base64'
			key			= "#{ stack }/#{ name }.zip"
			object		= await getObject { profile, region, bucket, key }

			return { key, fileHash, zipHash, size, object }
		)()
	)

	# hashBase64	= hash.toString 'base64'
	# hashHex		= hash.toString 'hex'

	# console.log key
	# console.log prev

	# console.log metadata, fileHash

	if object and object.metadata.filehash is fileHash
		warn "Unchanged Lambda: #{ name }.zip"
		return { key, fileHash, zipHash: object.metadata.ziphash, version: object.version }

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
		chalk"Uploading Lambda: {yellow #{ name }.zip} to S3 ({blue #{ filesize size }})"
		s3.putObject params
			.promise()
	)

	return { key, fileHash, zipHash, version: result.VersionId }
