"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function (directory) {
  var files, template;
  files = await (0, _listFilesRecursive2.default)(directory);
  files = files.filter(function (file) {
    var extension;
    extension = _path2.default.extname(file).toLowerCase();
    return ['.yml', '.yaml'].includes(extension);
  });

  if (files.length === 0) {
    throw new Error("AWS template directory has no template files inside.");
  }

  template = {};
  await Promise.all(files.map(async function (file) {
    var data, i, key, len, ref;
    data = await _fs2.default.promises.readFile(file);
    data = (0, _parse2.default)(data);
    data = data || {};
    ref = Object.keys(data); // Check if we find duplicate keys inside our template.

    for (i = 0, len = ref.length; i < len; i++) {
      key = ref[i];

      if (typeof template[key] !== 'undefined') {
        throw new Error(`AWS template has a duplicate key for: ${key}`);
      }
    }

    return Object.assign(template, data);
  }));
  return template;
};

var _fs = require("fs");

var _fs2 = _interopRequireDefault(_fs);

var _path = require("path");

var _path2 = _interopRequireDefault(_path);

var _parse = require("./parse");

var _parse2 = _interopRequireDefault(_parse);

var _listFilesRecursive = require("../fs/list-files-recursive");

var _listFilesRecursive2 = _interopRequireDefault(_listFilesRecursive);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;