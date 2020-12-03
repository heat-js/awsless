
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
import path 			from 'path'
import chalk			from 'chalk'

import { task, warn, info, err, confirm } from '../feature/console'
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
			if not await confirm chalk"Are u sure you want to {green deploy} the stack?"
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
		# Run events before stack update

		# 1
		await context.emitter.emit 'validate-resource'
		# 2
		await context.emitter.emit 'prepare-resource'
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
			await writeFile file, stack.template

		# -----------------------------------------------------
		# Log the template to the console

		###
			Todo...
		###

		# -----------------------------------------------------
		# Validate Templates & get the stack capabilities

		await context.emitter.emit 'before-validating-template'

		capabilities = await task(
			'Validate templates'
			Promise.all stacks.map (stack) ->
				return stack.capabilities = await validateTemplate stack
		)

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

		await task(
			"Deploying stack"
			Promise.all stacks.map (stack) ->
				return deployStack {
					stack:			stack.stack
					profile:		stack.profile
					region:			stack.region
					template:		stack.template
					capabilities:	stack.capabilities
				}
		)

		# -----------------------------------------------------
		# Run events after stack update

		await context.emitter.emit 'after-deploying-stack'

	catch error
		err error.message
