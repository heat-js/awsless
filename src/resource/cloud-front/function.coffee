
import fs 			from 'fs'
import path 		from 'path'
import CoffeeScript	from 'coffeescript'
import resource 	from '../../feature/resource'

export default resource (ctx) ->

	prefixName	= ctx.string '@Config.PrefixResourceName', ''
	name		= ctx.string [ 'Name' ]
	name		= "#{ prefixName }#{ name }"

	handle		= ctx.string 'Handle'
	filePath 	= path.join process.cwd(), handle

	if fs.existsSync filePath + '.coffee'
		code = fs.readFileSync filePath + '.coffee', 'utf8'
		code = CoffeeScript.compile code, {
			bare: true
		}

	else
		code = fs.readFileSync filePath + '.js', 'utf8'

	ctx.addResource ctx.name, {
		Type:	'AWS::CloudFront::Function'
		Region:	ctx.string '#Region', ''
		Properties: {
			Name: name
			AutoPublish: true
			FunctionCode: code
		}
	}
