
import load				from '../feature/template/load'
import resolveResources	from '../feature/template/resolve-resources'
import resolveVariables	from '../feature/template/resolve-variables'
import split 			from '../feature/template/split'
import deleteStack		from '../feature/cloudformation/delete-stack'
import removeDirectory 	from '../feature/fs/remove-directory'
import logStacks		from '../feature/terminal/log-stacks'
import chalk			from 'chalk'
import path				from 'path'

import { task, warn, err, confirm } from '../feature/console'
import { localResolvers, remoteResolvers, resources } from '../config'

export default (options) ->
	try
		# -----------------------------------------------------
		# Load the template files

		template = await task(
			'Loading templates'
			{ persist: false }
			load path.join process.cwd(), 'aws'
		)

		# -----------------------------------------------------
		# Resolve the local variable resolvers

		template = await task(
			'Resolve variables'
			{ persist: false }
			resolveVariables template, localResolvers
		)

		# -----------------------------------------------------
		# Resolve the remote variable resolvers

		template = await task(
			'Resolve variables'
			{ persist: false }
			resolveVariables template, remoteResolvers
		)

		# -----------------------------------------------------
		# Parse our custom resources

		context = await task(
			'Parsing custom resources'
			{ persist: false }
			resolveResources template, resources
		)

		# -----------------------------------------------------
		# Split the stack into multiple stacks if needed

		stacks = split context

		# -----------------------------------------------------
		# Log stack(s) information

		logStacks stacks.map (stack) -> {
			Stack:		stack.stack
			Region:		stack.region
			Profile:	stack.profile
		}

		# -----------------------------------------------------
		# Show confirm prompt

		if not options.skipPrompt
			if not await confirm chalk"Are u sure you want to {red delete} the stack?"
				warn 'Cancelled.'
				return

		# -----------------------------------------------------
		# Clean up previous build files

		cloudformationDir = path.join process.cwd(), '.awsless', 'cloudformation'

		await removeDirectory cloudformationDir

		await task(
			'Cleaning up'
			context.emitter.emit 'cleanup'
		)

		# -----------------------------------------------------
		# Run events before stack delete

		await context.emitter.emit 'before-deleting-stack'

		# -----------------------------------------------------
		# Deleting stack

		# Split the stacks again to make sure we have all the
		# template changes committed

		stacks = split context

		await task(
			"Deleting stack"
			Promise.all stacks.map (stack) ->
				return deleteStack {
					stack:		stack.stack
					profile:	stack.profile
					region:		stack.region
				}
		)

		# -----------------------------------------------------
		# Run events after stack delete

		await context.emitter.emit 'after-deleting-stack'

	catch error
		err error.message
