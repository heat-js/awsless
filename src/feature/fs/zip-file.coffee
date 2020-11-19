
import fs				from 'fs'
import JSZip			from 'jszip'
import { pipeline }		from 'stream'
import LengthStream		from 'length-stream'

export default (input, fileName, output) ->

	zip = new JSZip
	zip.file fileName, fs.createReadStream input
	source = zip.generateNodeStream { streamFiles:true }

	length 			= 0
	lengthStream	= LengthStream (result) -> length = result
	destination 	= fs.createWriteStream output

	return new Promise (resolve, reject) ->
		pipeline source, lengthStream, destination, (error) ->
			if error
				reject error
				return

			resolve length

# import { createReadStream, createWriteStream }	from 'fs'
# import { createGzip }							from 'zlib'
# import { pipeline }								from 'stream'
# import LengthStream								from 'length-stream'

# export default (input, output) ->

# 	gzip			= createGzip()
# 	source			= createReadStream input
# 	destination 	= createWriteStream output

# 	length 			= 0
# 	lengthStream	= LengthStream (result) -> length = result

# 	return new Promise (resolve, reject) ->
# 		pipeline source, gzip, lengthStream, destination, (error) ->
# 			if error
# 				reject error
# 				return

# 			resolve length
