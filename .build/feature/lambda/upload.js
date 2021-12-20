"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function ({
  profile,
  region,
  bucket,
  name,
  stack,
  handle,
  externals = [],
  files = {},
  policyChecksum = '',
  bugsnagApiKey,
  webpackConfig = {}
}) {
  var compFile, compPath, elapsed, file, key, outputPath, root, uncompFile, uncompPath, uncompZipFile, zipFile;
  root = process.cwd();
  file = handle;
  file = file.substr(0, file.lastIndexOf('.'));
  file = _path2.default.join(root, file);
  outputPath = _path2.default.join(root, '.awsless', 'lambda', name);
  uncompPath = _path2.default.join(outputPath, 'uncompressed');
  compPath = _path2.default.join(outputPath, 'compressed');
  uncompFile = _path2.default.join(uncompPath, `${name}.js`);
  compFile = _path2.default.join(compPath, `${name}.js`);
  uncompZipFile = _path2.default.join(uncompPath, 'index.zip');
  zipFile = _path2.default.join(compPath, 'index.zip');
  key = `${stack}/${name}.zip`;
  elapsed = (0, _time2.default)();
  return (0, _task.run)(function (task) {
    task.setPrefix('Lambda');
    task.setName(`${name}.zip`);
    task.setContent('Waiting...');
    return (0, _throttle2.default)(async function () {
      var checksum, hash, object, result, s3, size;
      task.setContent('Checking...');
      await build(file, uncompFile, {
        externals,
        minimize: false,
        webpackConfig
      });
      object = await getObject({
        profile,
        region,
        bucket,
        key
      });
      checksum = await (0, _hashThen2.default)(uncompPath);
      checksum = (0, _checksum2.default)([checksum, policyChecksum]); // checksum 	= checksum.substr 0, 16

      if (object && object.metadata.checksum === checksum) {
        task.warning();
        task.setContent('Unchanged');
        task.addMetadata('Time', elapsed());
        return {
          key,
          checksum,
          hash: object.metadata.hash,
          version: object.version,
          changed: false
        };
      }

      task.setContent('Building...');
      await build(file, compFile, {
        externals,
        minimize: true,
        webpackConfig
      });
      size = await (0, _zipFiles2.default)(compPath, zipFile);
      hash = await (0, _hashFile2.default)('sha256', zipFile, 'base64');
      s3 = (0, _s2.default)({
        profile,
        region
      });
      task.setContent('Uploading to S3...');
      task.addMetadata('Size', (0, _filesize2.default)(size));
      result = await s3.putObject({
        Bucket: bucket,
        Key: key,
        ACL: 'private',
        Body: (0, _fs.createReadStream)(zipFile),
        StorageClass: 'STANDARD',
        Metadata: {
          checksum,
          hash
        }
      }).promise();

      if (bugsnagApiKey) {
        task.setContent('Uploading source map to Bugsnag...');
        await (0, _uploadSourceMap2.default)({
          apiKey: bugsnagApiKey,
          name
        });
      }

      task.setContent('Uploaded to S3');
      task.addMetadata('Time', elapsed());
      return {
        key,
        checksum,
        hash,
        version: result.VersionId,
        changed: true
      };
    });
  });
};

var _s = require("../client/s3");

var _s2 = _interopRequireDefault(_s);

var _path = require("path");

var _path2 = _interopRequireDefault(_path);

var _hashFile = require("../crypto/hash-file");

var _hashFile2 = _interopRequireDefault(_hashFile);

var _checksum = require("../crypto/checksum");

var _checksum2 = _interopRequireDefault(_checksum);

var _zipFiles = require("../fs/zip-files");

var _zipFiles2 = _interopRequireDefault(_zipFiles);

var _fs = require("fs");

var _task = require("../terminal/task");

var _time = require("../performance/time");

var _time2 = _interopRequireDefault(_time);

var _throttle = require("../performance/throttle");

var _throttle2 = _interopRequireDefault(_throttle);

var _uploadSourceMap = require("../bugsnag/upload-source-map");

var _uploadSourceMap2 = _interopRequireDefault(_uploadSourceMap);

var _filesize = require("filesize");

var _filesize2 = _interopRequireDefault(_filesize);

var _chalk = require("chalk");

var _chalk2 = _interopRequireDefault(_chalk);

var _hashThen = require("hash-then");

var _hashThen2 = _interopRequireDefault(_hashThen);

var _threads = require("threads");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var build, getObject;

build = async function (input, output, options) {
  var error, result, worker;
  worker = await (0, _threads.spawn)(new _threads.Worker('./build'));

  try {
    result = await worker.build(input, output, options);
  } catch (error1) {
    error = error1;
    throw error;
  } finally {
    await _threads.Thread.terminate(worker);
  }

  return result;
}; // worker = new Worker require.resolve './build.js'
// const myWorker = new JestWorker(require.resolve('./Worker'), {
//     exposedMethods: ['foo', 'bar', 'getWorkerId'],
//     numWorkers: 4,
//   });
//   console.log(await myWorker.foo('Alice')); // "Hello from foo: Alice"
//   console.log(await myWorker.bar('Bob')); // "Hello from bar: Bob"
//   console.log(await myWorker.getWorkerId()); // "3" ->
// build = (inputFile, outputFile, options) ->
// 	new Worker
// 	# dir = path.join __dirname, './build'
// 	# worker = new Worker '../', { workerData: {num: 5}});


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