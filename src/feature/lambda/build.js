
const TerserPlugin	= require('terser-webpack-plugin');
const webpack		= require('webpack');
const path			= require('path');
const { expose }	= require('threads/worker');

const webpackOptions = {
	target: 'node',
	context: process.cwd(),
	// devtool: false,
	// devtool: 'hidden-source-map',
	node: {
		__dirname: false,
		__filename: false,
	},
	stats: 'minimal',
	performance: {
		// Turn off size warnings for entry points
		hints: false,
	},
	module: {
		strictExportPresence: true,
		rules: [
			{
				loader: require.resolve('coffee-loader'),
				test: /\.coffee$/,
			},
			{
				loader: require.resolve('node-loader'),
				test: /\.node$/,
			},
		],
	},
	resolve: {
		extensions: [ '.js', '.jsx', '.coffee' ],
	},
};

expose({
	build: function(inputFile, outputFile, options) {
		var options = {
			minimize: true,
			externals: [],
			...options,
		};

		return new Promise(function(resolve, reject) {
			const compiler = webpack(Object.assign({}, webpackOptions, {
				entry:	inputFile,
				mode:	options.minimize ? 'production' : 'development',
				devtool: options.minimize ? 'hidden-source-map' : false,
				optimization: {
					minimize: options.minimize,
					minimizer: [
						new TerserPlugin({
							parallel: true,
							terserOptions: {
								output: {
									comments: false,
								},
							},
						}),
					],
				},
				externals: [
					'aws-sdk',
					/^(aws\-sdk\/.*)$/i,
					...options.externals,
				],
				output: {
					path:							path.dirname(outputFile),
					filename:						path.basename(outputFile),
					libraryTarget:					'commonjs',
					strictModuleExceptionHandling:	true,
				},
			}));

			compiler.run(function(error, stats) {
				if(error) {
					return reject(error);
				}

				const data = stats.toJson();
				if(data.errors.length) {
					const info			= data.errors[ 0 ];
					const customError	= new Error(`${ info.message }\nFile: ${ info.moduleName }`);
					customError.file	= info.moduleName;
					customError.details	= info.details;
					return reject(customError);
				}

				resolve();
			});
		});
	},
});
