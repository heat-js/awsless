"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (alg, file, encoding) {
  var hash, stream;
  hash = _crypto2.default.createHash(alg);
  stream = _fs2.default.createReadStream(file).pipe(hash);
  return new Promise(function (resolve, reject) {
    return (0, _streamToBuffer2.default)(stream, function (error, buffer) {
      if (error) {
        reject(error);
        return;
      }

      return resolve(buffer.toString(encoding));
    });
  });
};

var _streamToBuffer = require("stream-to-buffer");

var _streamToBuffer2 = _interopRequireDefault(_streamToBuffer);

var _crypto = require("crypto");

var _crypto2 = _interopRequireDefault(_crypto);

var _fs = require("fs");

var _fs2 = _interopRequireDefault(_fs);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;