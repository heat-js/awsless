
const { rollup } 	= require('rollup');
const babel 		= require('rollup-plugin-babel');
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
					mainFields: ['main'],
					preferBuiltins: false,
					extensions: ['.js', '.coffee']
				}),
				commonjs(),
				terser(),
				babel({
					babelrc: false,
					extensions: [".js"],
					runtimeHelpers: true,
					exclude: ["node_modules/@babel/**"],
					presets: [
						[ "@babel/preset-env", {
							modules: false,
							targets: "defaults",
						} ],
					  ],
					// plugins: [
					// 	"@babel/plugin-syntax-dynamic-import",
					// 	[
					// 	  "@babel/plugin-transform-runtime",
					// 	  {
					// 		useESModules: true,
					// 	  },
					// 	],
					// ],
				}),
			]
		});

		const { output } = await bundle.generate({
			format: 		'iife',
			name: 			'handler',
			strict: 		false,
			indent: 		false,
    		sourcemap: 		false,
			esModule:		false,
		});

		code = output[0].code
		// code = code.replace('var handler=function', 'function handler')

		return code
	},
});
