"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function (context) {
  var buildDir, capabilities, error, file, i, j, len, len1, list, stack, stacks;
  stacks = (0, _split2.default)(context); // stackName	= context.string '@Config.Stack'
  // # region		= context.string '@Config.Region'
  // profile 	= context.string '@Config.Profile'
  // # console.log context, context.string '@Config.Stack'
  // # console.log templates
  // console.log util.inspect stacks, {
  // 	depth:	Infinity
  // 	colors: true
  // }
  // return

  (0, _logStacks2.default)(stacks.map(function (stack) {
    return {
      Stack: stack.name,
      Region: stack.region,
      Profile: stack.profile
    };
  })); // if not await confirm 'Are u sure?'
  // 	warn 'Cancelled.'
  // 	return
  // -----------------------------------------------------
  // Run events before stack update
  // resources:	Object.keys(template.Resources).length
  // outputs:	Object.keys(template.Outputs).length

  await (0, _console.task)('Cleaning up', context.emitter.emit('cleanup')); // await context.emitter.emit 'cleanup'

  await context.emitter.emit('validate-resource');
  await context.emitter.emit('prepare-resource'); // await context.emitter.emit 'pre-generate-template'
  // await context.emitter.emit 'generate-template'
  // await context.emitter.emit 'post-generate-template'
  // await context.emitter.emit 'pre-stack-deploy'
  // await context.emitter.emit 'beforeStackDeploy'
  // try
  // 	await context.emitter.emit 'beforeStackDeploy'
  // catch error
  // 	return err error.message
  // -----------------------------------------------------
  // Convert the template to JSON

  await context.emitter.emit('before-preparing-template');
  stacks = (0, _split2.default)(context);

  for (i = 0, len = stacks.length; i < len; i++) {
    stack = stacks[i];
    stack.template = (0, _stringify2.default)(stack.template);
  } // -----------------------------------------------------
  // Save stack templates in the build folder


  buildDir = _path2.default.join(process.cwd(), '.awsless', 'cloudformation');

  for (j = 0, len1 = stacks.length; j < len1; j++) {
    stack = stacks[j];
    file = _path2.default.join(buildDir, `${stack.name}.${stack.region}.json`);
    await (0, _writeFile2.default)(file, stack.template);
  } // -----------------------------------------------------
  // Validate Templates


  await context.emitter.emit('before-validating-template');

  try {
    // if
    // for stack in stacks
    // 	console.log util.inspect JSON.parse(stack.template), {
    // 		depth:	Infinity
    // 		colors: true
    // 	}
    // return
    capabilities = await (0, _console.task)('Validate templates', Promise.all(stacks.map(async function (stack) {
      return stack.capabilities = await (0, _validateTemplate2.default)(stack);
    })));
  } catch (error1) {
    error = error1;
    return (0, _console.err)(error.message);
  }

  list = capabilities.flat();

  if (list.length > 0) {
    (0, _console.info)(_chalk2.default`{white The stack is using the following capabilities:} ${list.join(', ')}`);
  } // try
  // 	capabilities = await task(
  // 		'Validate templates'
  // 		validateTemplate { profile, region, template }
  // 	)
  // catch error
  // 	return err error.message
  // -----------------------------------------------------
  // Deploying stack


  await context.emitter.emit('before-deploying-stack');

  try {
    await (0, _console.task)("Deploying stack", Promise.all(stacks.map(function (stack) {
      return (0, _deployStack2.default)({
        stackName: stack.name,
        profile: stack.profile,
        region: stack.region,
        template: stack.template,
        capabilities: stack.capabilities
      });
    })));
  } catch (error1) {
    error = error1;
    return (0, _console.err)(error.message);
  }

  try {
    // -----------------------------------------------------
    // Run events after stack update
    return await context.emitter.emit('after-deploying-stack');
  } catch (error1) {
    error = error1;
    return (0, _console.err)(error.message);
  }
};

var _objectPath = require("../object-path");

var _objectPath2 = _interopRequireDefault(_objectPath);

var _deployStack = require("../cloudformation/deploy-stack");

var _deployStack2 = _interopRequireDefault(_deployStack);

var _validateTemplate = require("../cloudformation/validate-template");

var _validateTemplate2 = _interopRequireDefault(_validateTemplate);

var _stringify = require("../template/stringify");

var _stringify2 = _interopRequireDefault(_stringify);

var _split = require("../template/split");

var _split2 = _interopRequireDefault(_split);

var _util = require("util");

var _util2 = _interopRequireDefault(_util);

var _path = require("path");

var _path2 = _interopRequireDefault(_path);

var _writeFile = require("../fs/write-file");

var _writeFile2 = _interopRequireDefault(_writeFile);

var _console = require("../console");

var _chalk = require("chalk");

var _chalk2 = _interopRequireDefault(_chalk);

var _logStacks = require("../terminal/log-stacks");

var _logStacks2 = _interopRequireDefault(_logStacks);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

;