
import Table	from 'tty-table'
import chalk	from 'chalk'
import { log }	from '../console'
import boxen	from 'boxen'

export default (stacks = []) ->
	if stacks.length is 1
		log boxen chalk"""
			{blue.bold Stack Information}

			{yellow Stack:} #{ stacks[0].stack }
			{yellow Region:} #{ stacks[0].region }
			{yellow Profile:} #{ stacks[0].profile }
			{yellow Resources:} #{ stacks[0].resources }
			{yellow Outputs:} #{ stacks[0].outputs }
		""", {
			borderStyle: 'round'
			borderColor: 'blue'
			dimBorder: true
			padding: 1
			margin: 1
		}

		return

	headers = [
		{
			align: 'right'
		}
		...stacks.map (_, index) -> {
			value: chalk"{blue.bold Stack ##{ index + 1 }}"
			align: 'left'
		}
	]

	rows = [ [
		chalk"""
			{yellow Stack}
			{yellow Region}
			{yellow Profile}
			{yellow Resources}
			{yellow Outputs}
		"""
		stacks.map (item, index) -> chalk"""
			#{ item.stack }
			#{ item.region }
			#{ item.profile }
			#{ item.resources }
			#{ item.outputs }
		"""
	] ]

	table = Table headers, rows, {
		paddingLeft: 2
		paddingRight: 2
		paddingTop: 1
		paddingBottom: 1
		marginLeft: 1
		borderColor: 'blue'
	}

	log table.render()
