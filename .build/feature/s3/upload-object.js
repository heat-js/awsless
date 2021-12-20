"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function ({
  profile,
  region,
  bucket,
  key,
  file,
  acl = 'private',
  cacheAge = 31536000
}) {
  var body, cacheControl, ext, s3;
  s3 = (0, _s2.default)({
    profile,
    region
  });
  ext = _path2.default.extname(file);

  cacheControl = function () {
    switch (_mimeTypes2.default.lookup(ext)) {
      case false:
      case 'text/html':
      case 'application/json':
      case 'application/manifest+json':
      case 'application/manifest':
      case 'text/markdown':
        return 's-maxage=31536000, max-age=0';

      default:
        return `public, max-age=${cacheAge}, immutable`;
    }
  }();

  body = await _fs2.default.promises.readFile(file);
  return await s3.putObject({
    ACL: acl,
    Bucket: bucket,
    Body: body,
    Key: key,
    CacheControl: cacheControl,
    ContentType: _mimeTypes2.default.contentType(ext) || 'text/html; charset=utf-8'
  }).promise();
};

var _fs = require("fs");

var _fs2 = _interopRequireDefault(_fs);

var _path = require("path");

var _path2 = _interopRequireDefault(_path);

var _mimeTypes = require("mime-types");

var _mimeTypes2 = _interopRequireDefault(_mimeTypes);

var _s = require("../client/s3");

var _s2 = _interopRequireDefault(_s);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;