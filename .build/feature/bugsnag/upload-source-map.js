"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = async function ({
  apiKey,
  name
}) {
  var projectRoot, root;
  root = process.cwd();
  projectRoot = _path2.default.join(root, '.awsless', 'lambda', name, 'compressed');
  return await _sourceMaps.browser.uploadOne({
    apiKey,
    bundleUrl: `${name}.js`,
    bundle: _path2.default.join(projectRoot, `${name}.js`),
    sourceMap: _path2.default.join(projectRoot, `${name}.js.map`),
    // projectRoot:	'/'
    projectRoot,
    overwrite: true
  });
};

var _path = require("path");

var _path2 = _interopRequireDefault(_path);

var _sourceMaps = require("@bugsnag/source-maps");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

// import { run }		from '../terminal/task'
// import time			from '../performance/time'
; // elapsed 		= time()
// return run (task) ->
// 	task.setPrefix 'Bugsnag'
// 	task.setName "#{ name }.map"
// 	task.setContent 'Uploading source map...'
// 	await browser.uploadOne {
// 		apiKey
// 		bundleUrl:		"#{ name }.js"
// 		bundle: 		path.join projectRoot, "#{ name }.js"
// 		sourceMap:		path.join projectRoot, "#{ name }.js.map"
// 		# projectRoot:	'/'
// 		projectRoot
// 		overwrite:		true
// 	}
// 	task.setContent 'Uploaded to Bugsnag'
// 	task.addMetadata 'Time', elapsed()