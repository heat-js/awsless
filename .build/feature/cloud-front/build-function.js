"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (handle) {
  var file, root;
  root = process.cwd();
  file = _path2.default.join(root, handle);
  return (0, _task.run)(async function (task) {
    var code;
    task.setPrefix('CloudFront Functions');
    task.setContent('Building...');
    code = await build(file);
    task.setContent('Done');
    task.addMetadata('Size', (0, _filesize2.default)(Buffer.byteLength(code, 'utf8')));
    return code;
  });
};

var _path = require("path");

var _path2 = _interopRequireDefault(_path);

var _task = require("../terminal/task");

var _filesize = require("filesize");

var _filesize2 = _interopRequireDefault(_filesize);

var _threads = require("threads");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var build;

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
};

;