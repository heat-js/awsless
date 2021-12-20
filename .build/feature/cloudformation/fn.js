"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var Select = exports.Select = function (number, ...array) {
  return {
    'Fn::Select': [number, ...array]
  };
};

var Split = exports.Split = function (sep, string) {
  return {
    'Fn::Split': [sep, string]
  };
};

var GetAtt = exports.GetAtt = function (...args) {
  return {
    'Fn::GetAtt': args
  };
};

var Ref = exports.Ref = function (resource) {
  return {
    'Ref': resource
  };
};

var Sub = exports.Sub = function (string) {
  return {
    'Fn::Sub': string
  };
};

var isFn = exports.isFn = function (object) {
  var keys;
  keys = Object.keys(object);

  if (keys.length !== 1) {
    return false;
  }

  return ['Ref', 'Fn::Sub', 'Fn::GetAtt', 'Fn::Split', 'Fn::Select', 'Fn::ImportValue'].includes(keys[0]);
};

var isArn = exports.isArn = function (string) {
  return typeof string === 'string' && 0 === string.indexOf('arn:');
};