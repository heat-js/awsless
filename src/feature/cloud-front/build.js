
const { rollup } 	= require('rollup');
const { babel, getBabelOutputPlugin } 	= require('@rollup/plugin-babel');
const { terser } 	= require('rollup-plugin-terser');
const coffeescript 	= require('rollup-plugin-coffee-script');
const commonjs 		= require('rollup-plugin-commonjs');
const nodeResolve 	= require('rollup-plugin-node-resolve');
const { expose } 	= require('threads/worker');
const builtins 		= require('builtin-modules');

expose({
	build: async function(inputFile) {
		const bundle = await rollup({
			input: inputFile,
			external: builtins,
			onwarn: function (message) {
				supressedWarnings = [
					'MISSING_GLOBAL_NAME',
					'MISSING_NODE_BUILTINS'
				]

				if (!supressedWarnings.includes(message.code)) {
					console.error(message.toString());
				}
			},
			plugins: [
				coffeescript(),
				nodeResolve({
					preferBuiltins: false,
					extensions: ['.js', '.coffee']
				}),
				commonjs(),
				getBabelOutputPlugin({
					allowAllFormats: true,
					presets: [ "@babel/preset-env" ]
				}),
				terser({
					compress: {
						negate_iife: false,
						defaults: false,
						ecma: 5,
					},
					mangle: true,
					toplevel: false,
				}),
			]
		});

		const { output } = await bundle.generate({
			format: 		'iife',
			name: 			'handler',
			strict: 		false,
			// indent: 		false,
    		// sourcemap: 		false,
			// esModule:		false,
		});

		code = output[0].code
		// code = code.replace('var handler=function', 'function handler')

		return code
	},
});
