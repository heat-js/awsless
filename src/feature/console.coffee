
import chalk	from 'chalk'
import Confirm	from 'prompt-confirm'
import symbols	from 'log-symbols'

export confirm = (message, options) ->
	entry = new Confirm {
		message
		default: false
		...options
	}

	return entry.run()

export log = (...args) ->
	console.log ...args

export warn = (message) ->
	return log chalk"{yellow #{ symbols.warning } #{ message }}"

export err = (message) ->
	return log chalk"{red #{ symbols.error } #{ message }}"

export info = (message) ->
	return log chalk"{blue #{ symbols.info } #{ message }}"

export keyval = (key, value) ->
	return log chalk"* {bold #{ key }}: {blue #{ value }}"
