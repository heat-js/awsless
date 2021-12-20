"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _fs = require("fs");

var _fs2 = _interopRequireDefault(_fs);

var _path = require("path");

var _path2 = _interopRequireDefault(_path);

var _isDirectory = require("./is-directory");

var _isDirectory2 = _interopRequireDefault(_isDirectory);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var isVisible, listFilesRecursive;

isVisible = function (file) {
  var i, len, part, parts;
  parts = file.split('/');

  for (i = 0, len = parts.length; i < len; i++) {
    part = parts[i];

    if (part.startsWith('_')) {
      return false;
    }
  }

  return true;
};

exports.default = listFilesRecursive = async function (directory) {
  var files;

  if (Array.isArray(directory)) {
    files = await Promise.all(directory.map(listFilesRecursive));
    return files.flat();
  }

  if (!(await (0, _isDirectory2.default)(directory))) {
    return [directory];
  }

  files = await _fs2.default.promises.readdir(directory);
  files = files.filter(isVisible);
  files = await Promise.all(files.map(file => {
    file = _path2.default.join(directory, file);
    return listFilesRecursive(file);
  }));
  return files.flat();
};