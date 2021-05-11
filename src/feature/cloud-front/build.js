
const { rollup } 	= require('rollup');
const coffeescript 	= require('rollup-plugin-coffee-script');
const nodeResolve 	= require('rollup-plugin-node-resolve');
const { terser } 	= require('rollup-plugin-terser');
const { expose } 	= require('threads/worker');

expose({
	build: async function(inputFile) {
		const bundle = await rollup({
			input: inputFile,
			plugins: [
				terser(),
				coffeescript(),
				nodeResolve({
					extensions: ['.js', '.coffee']
				}),
			]
		});

		const { output } = await bundle.generate({
			format: 'umd',
			name: 	'handler'
		});

		return output[0].code
	},
});
