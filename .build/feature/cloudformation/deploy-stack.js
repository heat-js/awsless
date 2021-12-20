"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function ({
  profile,
  region,
  stack,
  templateBody,
  templateUrl,
  capabilities = []
}) {
  var cloudFormation, elapsed;
  elapsed = (0, _time2.default)();
  cloudFormation = (0, _cloudformation2.default)({
    profile,
    region
  });
  return (0, _task.run)(async function (task) {
    var error, exists, params, result, state, status;
    task.setPrefix('Stack'); // task.setName chalk"#{ stack } {gray #{ region }}"

    task.setName(stack);
    task.setContent('Deploying...');
    task.addMetadata('Region', region);
    params = {
      StackName: stack,
      Capabilities: capabilities,
      Tags: [{
        Key: 'Stack',
        Value: stack
      }]
    };

    if (templateUrl) {
      params.TemplateURL = templateUrl;
    } else {
      params.TemplateBody = templateBody;
    }

    status = await (0, _stackStatus2.default)({
      profile,
      region,
      stack
    });
    exists = !(!status || status === 'ROLLBACK_COMPLETE');

    if (!exists) {
      result = await cloudFormation.createStack({ ...params,
        EnableTerminationProtection: false,
        OnFailure: 'ROLLBACK'
      }).promise();
    } else {
      if (status.includes('IN_PROGRESS')) {
        task.setContent('Failed');
        throw new Error(`Stack is in progress: ${status}`);
      }

      try {
        result = await cloudFormation.updateStack({ ...params
        }).promise();
      } catch (error1) {
        error = error1;

        if (error.message.includes('No updates are to be performed')) {
          // log.warning 'Nothing to deploy!'
          task.setContent('Unchanged');
          task.warning();
          task.addMetadata('Time', elapsed());
          return;
        }

        throw error;
      }
    }

    state = exists ? 'stackUpdateComplete' : 'stackCreateComplete';

    try {
      await cloudFormation.waitFor(state, {
        StackName: stack
      }).promise();
    } catch (error1) {
      error = error1;
      task.setContent('Failed');

      if (error.stack) {
        result = await cloudFormation.describeStackEvents({
          StackName: stack
        }).promise();
        throw new Error((0, _stackEventsError2.default)(result.StackEvents));
      }

      throw error;
    }

    task.setContent('Deployed');
    return task.addMetadata('Time', elapsed());
  });
};

var _cloudformation = require("../client/cloudformation");

var _cloudformation2 = _interopRequireDefault(_cloudformation);

var _stackStatus = require("./stack-status");

var _stackStatus2 = _interopRequireDefault(_stackStatus);

var _stackEventsError = require("./stack-events-error");

var _stackEventsError2 = _interopRequireDefault(_stackEventsError);

var _task = require("../terminal/task");

var _time = require("../performance/time");

var _time2 = _interopRequireDefault(_time);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

// import chalk			from 'chalk'
;