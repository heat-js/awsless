"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.resources = exports.logicalResolvers = exports.remoteResolvers = exports.localResolvers = undefined;

var _cf = require("./variable-resolver/cf");

var _cf2 = _interopRequireDefault(_cf);

var _env = require("./variable-resolver/env");

var _env2 = _interopRequireDefault(_env);

var _opt = require("./variable-resolver/opt");

var _opt2 = _interopRequireDefault(_opt);

var _var = require("./variable-resolver/var");

var _var2 = _interopRequireDefault(_var);

var _ssm = require("./variable-resolver/ssm");

var _ssm2 = _interopRequireDefault(_ssm);

var _attr = require("./variable-resolver/attr");

var _attr2 = _interopRequireDefault(_attr);

var _when = require("./variable-resolver/when");

var _when2 = _interopRequireDefault(_when);

var _output = require("./resource/output");

var _output2 = _interopRequireDefault(_output);

var _website = require("./resource/website");

var _website2 = _interopRequireDefault(_website);

var _api = require("./resource/appsync/api");

var _api2 = _interopRequireDefault(_api);

var _topic = require("./resource/sns/topic");

var _topic2 = _interopRequireDefault(_topic);

var _queue = require("./resource/sqs/queue");

var _queue2 = _interopRequireDefault(_queue);

var _bucket = require("./resource/s3/bucket");

var _bucket2 = _interopRequireDefault(_bucket);

var _object = require("./resource/s3/object");

var _object2 = _interopRequireDefault(_object);

var _schedule = require("./resource/schedule");

var _schedule2 = _interopRequireDefault(_schedule);

var _table = require("./resource/dynamodb/table");

var _table2 = _interopRequireDefault(_table);

var _function = require("./resource/lambda/function");

var _function2 = _interopRequireDefault(_function);

var _policy = require("./resource/lambda/policy");

var _policy2 = _interopRequireDefault(_policy);

var _layer = require("./resource/lambda/layer");

var _layer2 = _interopRequireDefault(_layer);

var _eventInvokeConfig = require("./resource/lambda/event-invoke-config");

var _eventInvokeConfig2 = _interopRequireDefault(_eventInvokeConfig);

var _function3 = require("./resource/cloud-front/function");

var _function4 = _interopRequireDefault(_function3);

var _stack = require("./resource/cloud-formation/stack");

var _stack2 = _interopRequireDefault(_stack);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var localResolvers = exports.localResolvers = {
  env: _env2.default,
  opt: _opt2.default,
  var: _var2.default,
  attr: _attr2.default
};
var remoteResolvers = exports.remoteResolvers = {
  ssm: _ssm2.default,
  cf: _cf2.default
};
var logicalResolvers = exports.logicalResolvers = {
  when: _when2.default
};
var resources = exports.resources = {
  'Awsless::Output': _output2.default,
  'Awsless::Website': _website2.default,
  'Awsless::Schedule': _schedule2.default,
  'Awsless::Appsync::Api': _api2.default,
  'Awsless::SNS::Topic': _topic2.default,
  'Awsless::SQS::Queue': _queue2.default,
  'Awsless::S3::Bucket': _bucket2.default,
  'Awsless::S3::Object': _object2.default,
  'Awsless::DynamoDB::Table': _table2.default,
  'Awsless::Lambda::Function': _function2.default,
  'Awsless::Lambda::Policy': _policy2.default,
  'Awsless::Lambda::Layer': _layer2.default,
  'Awsless::Lambda::AsyncConfig': _eventInvokeConfig2.default,
  'Awsless::CloudFront::Function': _function4.default,
  'Awsless::CloudFormation::Stack': _stack2.default
};