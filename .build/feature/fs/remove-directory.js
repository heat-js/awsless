"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function (directory) {
  return await _fs2.default.promises.rmdir(directory, {
    recursive: true
  });
};

var _fs = require("fs");

var _fs2 = _interopRequireDefault(_fs);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

; // import rimraf from 'rimraf'
// export default (directory) ->
// 	return new Promise (resolve, reject) ->
// 		rimraf directory, (error) ->
// 			if error then reject error
// 			else resolve()