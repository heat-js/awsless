
import toBuffer	from 'stream-to-buffer'
import crypto 	from 'crypto'
import fs 		from 'fs'

export default (file, encoding) ->
	hash = crypto.createHash 'sha256'

	stream = fs.createReadStream file
		.pipe hash

	return new Promise (resolve, reject) ->
		toBuffer stream, (error, buffer) ->
			if error
				reject error
				return

			resolve buffer.toString encoding
