"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
var Attribute;

var resolve = exports.resolve = function (data, globals) {
  var attr;
  attr = new Attribute(data.resource, data.name);
  return attr.resolve(globals);
};

var isAttr = exports.isAttr = function (value) {
  return value instanceof Attribute || value.__type__ === 'Attribute';
};

exports.default = Attribute = class Attribute {
  constructor(resource, name) {
    this.resource = resource;
    this.name = name;
    this.__type__ = 'Attribute';
  }

  resolve(globals) {
    return globals[`attr-${this.resource}-${this.name}`];
  }

};