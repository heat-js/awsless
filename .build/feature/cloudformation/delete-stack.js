"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function ({
  profile,
  region,
  stack
}) {
  return (0, _task.run)(async function (task) {
    var cloudFormation, elapsed, error, params, result, state, status;
    elapsed = (0, _time2.default)();
    task.setPrefix('Stack'); // task.setName chalk"#{ stack } {gray #{ region }}"

    task.setName(stack);
    task.setContent('Deleting...');
    task.addMetadata('Region', region);
    params = {
      StackName: stack
    };
    status = await (0, _stackStatus2.default)({
      profile,
      region,
      stack
    });

    if (!status) {
      task.setContent('Stack has already been deleted!');
      task.warning();
      return;
    }

    if (status.includes('IN_PROGRESS')) {
      task.setContent('Failed');
      throw new Error(`Stack is in progress: ${status}`);
    }

    cloudFormation = (0, _cloudformation2.default)({
      profile,
      region
    });
    result = await cloudFormation.deleteStack(params).promise();
    state = status ? 'stackDeleteComplete' : 'stackCreateComplete';

    try {
      await cloudFormation.waitFor('stackDeleteComplete', params).promise();
    } catch (error1) {
      error = error1;
      task.setContent('Failed');

      if (error.stack) {
        result = await cloudFormation.describeStackEvents(params).promise();
        throw new Error((0, _stackEventsError2.default)(result.StackEvents));
      }

      throw error;
    }

    task.setContent('Deleted');
    return task.addMetadata('Time', elapsed());
  });
};

var _cloudformation = require("../client/cloudformation");

var _cloudformation2 = _interopRequireDefault(_cloudformation);

var _task = require("../terminal/task");

var _time = require("../performance/time");

var _time2 = _interopRequireDefault(_time);

var _stackStatus = require("./stack-status");

var _stackStatus2 = _interopRequireDefault(_stackStatus);

var _stackEventsError = require("./stack-events-error");

var _stackEventsError2 = _interopRequireDefault(_stackEventsError);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;