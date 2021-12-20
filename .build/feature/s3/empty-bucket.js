"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function ({
  profile,
  region,
  bucket
}) {
  var count, file, files, i, len, result, s3, size;
  s3 = (0, _s2.default)({
    profile,
    region
  });
  count = 0;
  size = 0;

  while (true) {
    result = await s3.listObjectsV2({
      Bucket: bucket
    }).promise();

    if (!result) {
      _log2.default.warning('Bucket not found!');

      break;
    }

    files = result.Contents || [];

    if (files.length === 0) {
      break;
    }

    result = await s3.deleteObjects({
      Bucket: bucket,
      Delete: {
        Objects: files.map(function ({
          Key
        }) {
          return {
            Key
          };
        }),
        Quiet: true
      }
    }).promise();

    for (i = 0, len = files.length; i < len; i++) {
      file = files[i];
      count++;
      size += file.Size;
    }
  }

  return {
    count,
    size
  };
};

var _s = require("../client/s3");

var _s2 = _interopRequireDefault(_s);

var _log = require("../terminal/log");

var _log2 = _interopRequireDefault(_log);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;