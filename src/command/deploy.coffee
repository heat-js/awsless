
import load				from '../feature/template/load'
import resolveResources	from '../feature/template/resolve-resources'
import resolveVariables	from '../feature/template/resolve-variables'
import stringify		from '../feature/template/stringify'
import deployStack		from '../feature/cloudformation/deploy-stack'
import validateTemplate	from '../feature/cloudformation/validate-template'
import split 			from '../feature/template/split'
import writeFile 		from '../feature/fs/write-file'
import removeDirectory 	from '../feature/fs/remove-directory'
import logStacks		from '../feature/terminal/log-stacks'
# import { log }			from '../feature/console'
import path 			from 'path'
import chalk			from 'chalk'
import util				from 'util'
import jsonFormat		from 'json-format'

import { run } from '../feature/terminal/task'

import { log, warn, info, err, confirm } from '../feature/console'
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
			if not await confirm chalk"Are u sure you want to {green deploy} the stack?"
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
		# Run events before stack update

		# 1
		await context.emitter.emit 'validate-resource'

		# 2
		await context.emitter.emitParallel 'prepare-resource'

		# 3
		await context.emitter.emit 'before-stringify-template'

		# -----------------------------------------------------
		# Convert the template to JSON

		# Split the stacks again to make sure we have all the
		# template changes committed

		stacks = split context

		for stack in stacks
			stack.template = stringify stack.template

		# -----------------------------------------------------
		# Save a copy of the stack templates in the build
		# folder

		for stack in stacks
			file = path.join cloudformationDir, "#{ stack.stack }.#{ stack.region }.json"
			json = JSON.parse stack.template
			await writeFile file, jsonFormat json

		# -----------------------------------------------------
		# Log the template to the console

		if options.preview
			for stack, index in stacks
				info "Stack #{ index }:"
				json = JSON.parse stack.template
				log util.inspect json, false, null, true

		# -----------------------------------------------------
		# Validate Templates & get the stack capabilities

		await context.emitter.emit 'before-validating-template'

		capabilities = await run (task) ->
			task.setContent 'Validate templates...'

			return Promise.all stacks.map (stack) ->
				return stack.capabilities = await validateTemplate stack


		# -----------------------------------------------------
		# Log the stack capabilities

		if options.capabilities
			list = capabilities.flat()
			if list.length > 0
				info chalk"{white The stack is using the following capabilities:} #{ list.join ', ' }"
			else
				info chalk.white 'The stack is using no special capabilities'

		# -----------------------------------------------------
		# Deploying stack

		await context.emitter.emit 'before-deploying-stack'

		await run (task) ->
			task.setContent "Deploying stack..."

			return Promise.all stacks.map (stack) ->
				return deployStack {
					stack:			stack.stack
					profile:		stack.profile
					region:			stack.region
					template:		stack.template
					capabilities:	stack.capabilities
				}


		# -----------------------------------------------------
		# Run events after stack update

		await context.emitter.emit 'after-deploying-stack'

	catch error
		err error.message

	process.exit 0
