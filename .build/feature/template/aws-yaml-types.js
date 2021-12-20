"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _jsYaml = require("js-yaml");

var _jsYaml2 = _interopRequireDefault(_jsYaml);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var customType;

// class Model
customType = function (name, kind) {
  return new _jsYaml2.default.Type(`!${name}`, {
    kind,
    instanceOf: Object,
    construct: function (data) {
      var object, prefix;
      object = {}; // model = new Model
      // model._data = data

      prefix = name === 'Ref' ? '' : 'Fn::';

      object[`${prefix}${name}`] = function () {
        switch (kind) {
          case 'scalar':
            return data;

          case 'sequence':
            return data || [];

          case 'mapping':
            return data || {};
        }
      }();

      return object;
    }
  });
}; // represent: (model) ->
// 	return model._data


exports.default = [customType('Base64', 'mapping'), customType('ImportValue', 'mapping'), customType('Ref', 'scalar'), customType('Sub', 'scalar'), customType('GetAZs', 'scalar'), customType('GetAtt', 'scalar'), customType('Condition', 'scalar'), customType('ImportValue', 'scalar'), customType('Cidr', 'scalar'), customType('And', 'sequence'), customType('Equals', 'sequence'), customType('GetAtt', 'sequence'), customType('If', 'sequence'), customType('FindInMap', 'sequence'), customType('Join', 'sequence'), customType('Not', 'sequence'), customType('Or', 'sequence'), customType('Select', 'sequence'), customType('Sub', 'sequence'), customType('Split', 'sequence'), customType('Cidr', 'sequence')];