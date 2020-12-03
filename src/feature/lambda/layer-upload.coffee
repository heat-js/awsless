
import Client				from '../client/s3'
import path					from 'path'
import { createReadStream }	from 'fs'
import { task, warn }		from '../console'
import time					from '../performance/time'
import chalk				from 'chalk'
import createChecksum		from 'hash-then'

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

export default ({ stack, profile, region, bucket, name, zip }) ->

	root	= process.cwd()
	file	= path.join root, zip
	key		= "#{ stack }/#{ name }-layer.zip"
	elapsed = time()

	{ checksum, object } = await task(
		chalk"Checking Lambda Layer: {yellow #{ name }-layer.zip}"
		{ persist: false }
		(->
			checksum	= await createChecksum file
			checksum 	= checksum.substr 0, 16
			object		= await getObject { profile, region, bucket, key }

			return { checksum, object }
		)()
	)

	if object and object.metadata.checksum is checksum
		warn chalk"{white Unchanged Lambda Layer: {yellow #{ name }-layer.zip} (build: {blue #{ elapsed() }})}"
		return { key, version: object.version }

	s3 = Client { profile, region }

	params = {
		Bucket: 		bucket
		Key:			key
		ACL:			'private'
		Body:			createReadStream file
		StorageClass:	'STANDARD'
		Metadata: {
			checksum
		}
	}

	result = await task(
		chalk"Uploading Lambda Layer: {yellow #{ name }-layer.zip} to S3 (build: {blue #{ elapsed() }})"
		s3.putObject params
			.promise()
	)

	return { key, version: result.VersionId }
