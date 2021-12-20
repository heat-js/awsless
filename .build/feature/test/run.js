"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

exports.default = function () {
  var test;
  test = (0, _child_process.spawn)('yarn', ['test'], {
    cwd: process.cwd(),
    stdio: 'inherit'
  });
  return new Promise(function (resolve) {
    return test.on('close', function (code) {
      return resolve(code === 0);
    });
  });
};

var _child_process = require("child_process");

; // test = spawn 'yarn test', {
// 	cwd: process.cwd()
// 	stdio: 'inherit'
// }
// return new Promise (resolve, reject) ->
// 	test.stdout.on 'data', (data) ->
// 		console.log 'STDOUT', data
// 	test.stderr.on 'data', (data) ->
// 		console.log 'STDERR', data
// 	test.on 'close', (code) ->
// 		console.log 'code', code
// 		resolve()