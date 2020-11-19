
import ora		from 'ora'
import chalk	from 'chalk'
import boxen	from 'boxen'
import Confirm	from 'prompt-confirm'
import symbols	from 'log-symbols'

busy	= false
queue	= []

export flush = ->
	if busy
		return

	while queue.length
		text = queue.pop()
		process.stdout.write "#{ text }\n"

export task = (text, options, promise) ->
	if not promise
		promise = options
		options = {}

	options = Object.assign { persist: true }, options, { text: "#{ text }..." }
	spinner = ora options
	spinner.start()
	busy = true

	try
		result = await promise

	catch error
		spinner.fail()
		busy = false
		flush()
		throw error

	if options.persist
		spinner.succeed()
	else
		spinner.stop()

	busy = false
	flush()

	return result


export confirm = (message, options) ->
	entry = new Confirm {
		message
		default: false
		...options
	}

	return entry.run()


export box = (text, options) ->
	queue.push boxen text, {
		borderStyle: 'round'
		borderColor: 'blue'
		dimBorder: true
		padding: 1
		margin: 1
		...options
	}

	flush()


export log = (message, { color } = {}) ->
	if color
		message = chalk[ color ] message

	queue.push message
	flush()

export warn = (message) ->
	return log "#{ symbols.warning } #{ message }", { color: 'yellow' }

export err = (message) ->
	return log "#{ symbols.error } Error: #{ message }", { color: 'red' }

export info = (message) ->
	return log "#{ symbols.info } #{ message }", { color: 'blue' }

export keyval = (key, value) ->
	return log chalk"* {bold #{ key }}: {blue #{ value }}"
