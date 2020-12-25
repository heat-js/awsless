
import load				from '../feature/template/load'
import resolveResources	from '../feature/template/resolve-resources'
import resolveVariables	from '../feature/template/resolve-variables'
import split 			from '../feature/template/split'
import deleteStack		from '../feature/cloudformation/delete-stack'
import removeDirectory 	from '../feature/fs/remove-directory'
import logStacks		from '../feature/terminal/log-stacks'
import chalk			from 'chalk'
import path				from 'path'

import { run } from '../feature/terminal/task'
import { warn, err, confirm } from '../feature/console'
import { localResolvers, remoteResolvers, resources } from '../config'

export default (options) ->

	try

		context = await run (task) ->
			# -----------------------------------------------------
			# Load the template files

			task.setContent "Loading templates..."

			template = await load path.join process.cwd(), 'aws'

			# -----------------------------------------------------
			# Resolve the local variable resolvers

			task.setContent "Resolve variables..."

			template = await resolveVariables template, localResolvers

			# -----------------------------------------------------
			# Resolve the remote variable resolvers

			template = await resolveVariables template, remoteResolvers

			# -----------------------------------------------------
			# Parse our custom resources

			task.setContent "Parsing resources..."

			context = await resolveResources template, resources

			# task.setContent "Parsing resources"

			return context

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

		await run (task) ->
			task.setContent 'Cleaning up...'
			await Promise.all [
				removeDirectory cloudformationDir
				context.emitter.emit 'cleanup'
			]

		# -----------------------------------------------------
		# Run events before stack delete

		await context.emitter.emit 'before-deleting-stack'

		# -----------------------------------------------------
		# Split the stacks again to make sure we have all the
		# template changes committed

		stacks = split context

		# -----------------------------------------------------
		# Deleting stack

		await run (task) ->
			task.setContent "Deleting stack..."

			return Promise.all stacks.map (stack) ->
				return deleteStack {
					stack:		stack.stack
					profile:	stack.profile
					region:		stack.region
				}

		# -----------------------------------------------------
		# Run events after stack delete

		await context.emitter.emit 'after-deleting-stack'

	catch error
		err error.message

	process.exit 0
