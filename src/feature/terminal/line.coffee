
import { into } from 'draftlog'

into console
	.addLineListener process.stdin

export default class TerminalLine

	constructor: ->
		@draft = console.draft()

	update: (text) ->
		@draft text
