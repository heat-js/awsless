"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function (folder, output, options = {}) {
  var destination, fileName, files, i, len, length, lengthStream, params, source, sourceFile, zip;
  options = {
    minimize: true,
    ...options
  };
  files = await _getAllFiles2.default.async.array(folder);
  files = files.filter(function (file) {
    switch (_path2.default.extname(file)) {
      case '.txt':
        return false;

      case '.map':
        return false;

      default:
        return true;
    }
  });
  zip = new _jszip2.default();

  for (i = 0, len = files.length; i < len; i++) {
    sourceFile = files[i];
    fileName = sourceFile.replace(folder, '');
    zip.file(fileName, _fs2.default.createReadStream(sourceFile));
  } // console.log files
  // for key, source of files
  // 	source = path.join process.cwd(), source
  // 	list = await getAllFiles.async.array source
  // 	# console.log key
  // 	# console.log source
  // 	# console.log list
  // 	for sourceFile in list
  // 		file = sourceFile.replace source, ''
  // 		file = path.join key, file
  // 		zip.file file, fs.createReadStream sourceFile
  // 	# 	console.log 'file', file
  // 	# 	# source


  params = {
    streamFiles: true
  };

  if (options.minimize) {
    params = { ...params,
      compression: 'DEFLATE',
      compressionOptions: {
        level: 9
      }
    };
  }

  length = 0;
  lengthStream = (0, _lengthStream2.default)(function (result) {
    return length = result;
  });
  source = zip.generateNodeStream(params);
  destination = _fs2.default.createWriteStream(output);
  return new Promise(function (resolve, reject) {
    return (0, _stream.pipeline)(source, lengthStream, destination, function (error) {
      if (error) {
        reject(error);
        return;
      }

      return resolve(length);
    });
  });
};

var _fs = require("fs");

var _fs2 = _interopRequireDefault(_fs);

var _path = require("path");

var _path2 = _interopRequireDefault(_path);

var _jszip = require("jszip");

var _jszip2 = _interopRequireDefault(_jszip);

var _stream = require("stream");

var _lengthStream = require("length-stream");

var _lengthStream2 = _interopRequireDefault(_lengthStream);

var _getAllFiles = require("get-all-files");

var _getAllFiles2 = _interopRequireDefault(_getAllFiles);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

; // import { createReadStream, createWriteStream }	from 'fs'
// import { createGzip }							from 'zlib'
// import { pipeline }								from 'stream'
// import LengthStream								from 'length-stream'
// export default (input, output) ->
// 	gzip			= createGzip()
// 	source			= createReadStream input
// 	destination 	= createWriteStream output
// 	length 			= 0
// 	lengthStream	= LengthStream (result) -> length = result
// 	return new Promise (resolve, reject) ->
// 		pipeline source, gzip, lengthStream, destination, (error) ->
// 			if error
// 				reject error
// 				return
// 			resolve length