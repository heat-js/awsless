"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function ({
  template,
  resource,
  properties,
  paths,
  type,
  defaultValue
}) {
  var i, len, object, path, value, valueType;

  if (!Array.isArray(paths)) {
    paths = [paths];
  }

  for (i = 0, len = paths.length; i < len; i++) {
    path = paths[i];

    if (path[0] === '@') {
      path = path.substr(1);
      object = template;
    } else if (path[0] === '#') {
      path = path.substr(1);
      object = resource;
    } else {
      object = properties;
    }

    value = _objectPath2.default.get(object, path);
    valueType = (0, _typeOf2.default)(value);

    if (valueType === 'undefined') {
      continue;
    }

    if (type && valueType !== type) {
      if (type === 'string' && valueType === 'object' && ((0, _fn.isFn)(value) || (0, _attribute.isAttr)(value))) {
        return value;
      }

      throw new TypeError(`Property \"${path}\" isnt a \"${type}\".`);
    }

    return value;
  }

  if (typeof defaultValue !== 'undefined') {
    return defaultValue;
  }

  throw new TypeError(`Property not defined with path \"${paths.join(', ')}\"`);
};

var _typeOf = require("type-of");

var _typeOf2 = _interopRequireDefault(_typeOf);

var _objectPath = require("object-path");

var _objectPath2 = _interopRequireDefault(_objectPath);

var _attribute = require("../attribute");

var _fn = require("./cloudformation/fn");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;