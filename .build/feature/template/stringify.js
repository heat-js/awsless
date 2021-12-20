"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function (template, globals) {
  return JSON.stringify(template, function (key, value) {
    var parts;

    if (key === 'Region') {
      return;
    }

    if (key === 'Fn::GetAtt' && typeof value === 'string') {
      parts = value.split('.');
      return [parts.shift(), parts.join('.')];
    }

    if (typeof value === 'object') {
      if ((0, _attribute.isAttr)(value)) {
        return (0, _attribute.resolve)(value, globals);
      }

      if (value instanceof _reference2.default) {
        return value.toJSON();
      }
    }

    return value;
  });
};

var _attribute = require("../../attribute");

var _reference = require("../../reference");

var _reference2 = _interopRequireDefault(_reference);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;