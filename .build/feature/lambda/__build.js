"use strict";

var _terserWebpackPlugin = require("terser-webpack-plugin");

var _terserWebpackPlugin2 = _interopRequireDefault(_terserWebpackPlugin);

var _webpack = require("webpack");

var _webpack2 = _interopRequireDefault(_webpack);

var _path = require("path");

var _path2 = _interopRequireDefault(_path);

var _worker = require("threads/worker");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

// import nodeExternals	from 'webpack-node-externals'
var webpackOptions;
// import nodeLoader		from 'node-loader'
// import coffeeLoader		from 'coffee-loader'
webpackOptions = {
  target: 'node',
  context: process.cwd(),
  devtool: false,
  node: {
    __dirname: false,
    __filename: false
  },
  // externals: [ nodeExternals(), 'aws-sdk' ]
  stats: 'minimal',
  performance: {
    // Turn off size warnings for entry points
    hints: false
  },
  module: {
    strictExportPresence: true,
    rules: [{
      loader: require.resolve('coffee-loader'),
      test: /\.coffee$/
    }, {
      loader: require.resolve('node-loader'),
      test: /\.node$/
    }]
  },
  resolve: {
    extensions: ['.js', '.jsx', '.coffee']
  }
};
(0, _worker.expose)({
  build: function (inputFile, outputFile, options) {
    // await new Promise (resolve) ->
    // 	setTimeout resolve, 1000
    // return true
    options = {
      minimize: true,
      externals: [],
      ...options
    };
    return new Promise(function (resolve, reject) {
      var compiler;
      compiler = (0, _webpack2.default)(Object.assign({}, webpackOptions, {
        entry: inputFile,
        mode: options.minimize ? 'production' : 'development',
        optimization: {
          minimize: options.minimize,
          minimizer: [new _terserWebpackPlugin2.default({
            parallel: true,
            terserOptions: {
              output: {
                comments: false
              }
            }
          })]
        },
        externals: ['aws-sdk', ...options.externals],
        output: {
          path: _path2.default.dirname(outputFile),
          filename: _path2.default.basename(outputFile),
          libraryTarget: 'commonjs',
          strictModuleExceptionHandling: true
        }
      }));
      return compiler.run(function (error, stats) {
        var data, info;

        if (error) {
          reject(error);
          return;
        }

        data = stats.toJson();

        if (data.errors.length) {
          info = data.errors[0];
          error = new Error(`${info.message}
File: ${info.moduleName}`);
          error.file = info.moduleName;
          error.details = info.details; // console.error data.errors

          reject(error);
          return;
        }

        return resolve(stats);
      });
    });
  }
});