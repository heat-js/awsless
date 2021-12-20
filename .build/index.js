"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.load = undefined;

var _load = require("./feature/template/load");

var _load2 = _interopRequireDefault(_load);

var _resolveResources = require("./feature/template/resolve-resources");

var _resolveResources2 = _interopRequireDefault(_resolveResources);

var _resolveVariables = require("./feature/template/resolve-variables");

var _resolveVariables2 = _interopRequireDefault(_resolveVariables);

var _split = require("./feature/template/split");

var _split2 = _interopRequireDefault(_split);

var _stringify = require("./feature/template/stringify");

var _stringify2 = _interopRequireDefault(_stringify);

var _config = require("./config");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var load = exports.load = async function (path, {
  resolveLocalResolvers = true,
  resolveRemoteResolvers = true,
  resolveLogicalResolvers = true
} = {}) {
  var context, template;
  template = await (0, _load2.default)(path);

  if (resolveLocalResolvers) {
    template = await (0, _resolveVariables2.default)(template, _config.localResolvers);
  }

  if (resolveRemoteResolvers) {
    template = await (0, _resolveVariables2.default)(template, _config.remoteResolvers);
  }

  if (resolveLogicalResolvers) {
    template = await (0, _resolveVariables2.default)(template, _config.logicalResolvers);
  }

  context = await (0, _resolveResources2.default)(template, _config.resources);
  return (0, _split2.default)(context).map(function (stack) {
    return { ...stack,
      templateBody: (0, _stringify2.default)(stack.templateBody, context.globals)
    };
  });
};