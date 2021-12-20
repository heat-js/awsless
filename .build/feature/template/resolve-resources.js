"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function (template, customResources = {}) {
  var context, customResource, emitter, name, resource, type;
  emitter = new _emitter2.default();
  context = new _context2.default({
    template,
    emitter
  });

  for (name in template) {
    resource = template[name];
    type = resource.Type || '';
    customResource = customResources[type];

    if (customResource) {
      await customResource(context, name, resource.Properties || {}, resource);
    } else if (0 === type.indexOf('AWS::')) {
      context.addResource(name, resource);
    }
  }

  return context;
};

var _context = require("../../context");

var _context2 = _interopRequireDefault(_context);

var _emitter = require("../../emitter");

var _emitter2 = _interopRequireDefault(_emitter);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;