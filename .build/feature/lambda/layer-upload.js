"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function ({
  stack,
  profile,
  region,
  bucket,
  name,
  zip
}) {
  var elapsed, file, key, root;
  root = process.cwd();
  file = _path2.default.join(root, zip);
  key = `${stack}/${name}-layer.zip`;
  elapsed = (0, _time2.default)();
  return (0, _task.run)(async function (task) {
    var checksum, object, result, s3;
    task.setPrefix('Lambda Layer');
    task.setName(`${name}-layer.zip`);
    task.setContent('Checking...');
    checksum = await (0, _hashThen2.default)(file);
    checksum = checksum.substr(0, 16);
    object = await getObject({
      profile,
      region,
      bucket,
      key
    });

    if (object && object.metadata.checksum === checksum) {
      task.warning();
      task.setContent('Unchanged');
      task.addMetadata('Time', elapsed());
      return {
        key,
        version: object.version
      };
    }

    task.setContent('Uploading...');
    s3 = (0, _s2.default)({
      profile,
      region
    });
    result = await s3.putObject({
      Bucket: bucket,
      Key: key,
      ACL: 'private',
      Body: (0, _fs.createReadStream)(file),
      StorageClass: 'STANDARD',
      Metadata: {
        checksum
      }
    }).promise();
    task.setContent('Uploaded to S3');
    return {
      key,
      version: result.VersionId
    };
  });
};

var _s = require("../client/s3");

var _s2 = _interopRequireDefault(_s);

var _path = require("path");

var _path2 = _interopRequireDefault(_path);

var _fs = require("fs");

var _task = require("../terminal/task");

var _time = require("../performance/time");

var _time2 = _interopRequireDefault(_time);

var _chalk = require("chalk");

var _chalk2 = _interopRequireDefault(_chalk);

var _hashThen = require("hash-then");

var _hashThen2 = _interopRequireDefault(_hashThen);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var getObject;

getObject = async function ({
  region,
  profile,
  bucket,
  key
}) {
  var error, result, s3;
  s3 = (0, _s2.default)({
    profile,
    region
  });

  try {
    result = await s3.headObject({
      Bucket: bucket,
      Key: key
    }).promise();
  } catch (error1) {
    error = error1;

    if (error.code === 'NotFound') {
      return;
    }

    throw error;
  }

  return {
    metadata: result.Metadata,
    version: result.VersionId
  };
};

;