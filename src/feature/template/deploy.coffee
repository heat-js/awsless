
import objectPath		from '../object-path'
import deployStack		from '../cloudformation/deploy-stack'
import validateTemplate	from '../cloudformation/validate-template'
import stringify		from '../template/stringify'
import util 			from 'util'

import { task, warn, info, err, confirm, box }	from '../console'
import chalk								from 'chalk'
import logStacks							from '../terminal/log-stacks'

export default ({ context, template }) ->

	stackName	= context.string '@Config.Stack'
	region		= context.string '@Config.Region'
	profile 	= context.string '@Config.Profile'

	logStacks [{
		stack:		stackName
		region
		profile
		resources:	Object.keys(template.Resources).length
		outputs:	Object.keys(template.Outputs).length
	}]

	# box chalk"""
	# 	{blue.bold Stack Information}

	# 	{yellow Stack:} #{ stackName }
	# 	{yellow Region:} #{ region }
	# 	{yellow Profile:} #{ profile }
	# 	{yellow Resources:} #{ Object.keys(template.Resources).length }
	# 	{yellow Outputs:} #{ Object.keys(template.Outputs).length }
	# """

	# if not await confirm 'Are u sure?'
	# 	warn 'Cancelled.'
	# 	return

	# await context.emitter.emit 'pre-stack-deploy'

	# -----------------------------------------------------
	# Run events before stack update

	await context.emitter.emit 'validate-resource'
	await context.emitter.emit 'prepare-resource'

	# await context.emitter.emit 'pre-generate-template'
	# await context.emitter.emit 'generate-template'
	# await context.emitter.emit 'post-generate-template'

	# await context.emitter.emit 'pre-stack-deploy'
	# await context.emitter.emit 'beforeStackDeploy'

	# try
	# 	await context.emitter.emit 'beforeStackDeploy'

	# catch error
	# 	return err error.message

	# -----------------------------------------------------
	# Convert the template to JSON

	await context.emitter.emit 'before-preparing-template'

	template = stringify template

	# -----------------------------------------------------
	# Validate Templates

	await context.emitter.emit 'before-validating-template'

	# console.log util.inspect JSON.parse(template), {
	# 	depth:	Infinity
	# 	colors: true
	# }

	# return

	try
		capabilities = await task(
			'Validate templates'
			validateTemplate { profile, region, template }
		)

	catch error
		return err error.message

	# -----------------------------------------------------
	# Deploying stack

	await context.emitter.emit 'before-deploying-stack'

	if capabilities.length > 0
		info chalk"{white The stack is using the following capabilities:} #{ capabilities.join ', ' }"

	try
		await task(
			"Deploying stack"
			deployStack { profile, region, stackName, template, capabilities }
		)

	catch error
		return err error.message

	# -----------------------------------------------------
	# Run events after stack update

	try
		await context.emitter.emit 'after-deploying-stack'

	catch error
		return err error.message
