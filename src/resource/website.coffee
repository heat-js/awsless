
import sync				from '@heat/s3-deploy/sync'
import path				from 'path'
import resource 		from '../feature/resource'
import isDirectory		from '../feature/fs/is-directory'
import clearCache		from '../feature/cloudfront/clear-cache'
import { task, keyval }	from '../feature/console'
import fetchExports		from '../feature/fetch/exports'
import output			from './output'

import { parseDomain, ParseResultType }	from 'parse-domain'
import { Ref, Select, Split, GetAtt }	from '../feature/cloudformation/fn'

formatHostedZoneName = (domain) ->
	result = parseDomain domain

	if result.type isnt ParseResultType.Listed
		throw new TypeError "Invalid Website DomainName: #{ domain }"

	return "#{ result.domain }.#{ result.topLevelDomains.join '.' }."

export default resource (ctx) ->

	Stack 				= ctx.string '@Config.Stack'
	DomainName			= ctx.string 'DomainName'
	BucketName			= ctx.string [ 'BucketName', 'DomainName' ]
	HostedZoneId		= ctx.string 'HostedZoneId', 'Z2FDTNDATAQYW2'
	HostedZoneName		= formatHostedZoneName DomainName
	AcmCertificateArn	= ctx.string 'Certificate', ''

	# -------------------------------------------------------
	# Make the s3 bucket

	ctx.addResource "#{ ctx.name }S3Bucket", {
		Type: 'AWS::S3::Bucket'
		Properties: {
			BucketName
			AccessControl:			ctx.string 'AccessControl', 'Private'
			WebsiteConfiguration: {
				ErrorDocument:		ctx.string 'ErrorDocument', 'index.html'
				IndexDocument:		ctx.string 'IndexDocument', 'index.html'
			}
		}
	}

	# -------------------------------------------------------
	# Make the route53 record set

	ctx.addResource "#{ ctx.name }Route53Record", {
		Type: 'AWS::Route53::RecordSet'
		Properties: {
			HostedZoneName
			Name: "#{ DomainName }."
			Type: 'A'
			AliasTarget: {
				DNSName: GetAtt "#{ ctx.name }CloudFrontDistribution", 'DomainName'
				HostedZoneId
			}
		}
	}

	# -------------------------------------------------------
	# Make the cloudfront distribution

	ctx.addResource "#{ ctx.name }CloudFrontDistribution", {
		Type: 'AWS::CloudFront::Distribution'
		Properties: {
			DistributionConfig: {
				Enabled: true
				DefaultRootObject: '/'
				Aliases: [ DomainName ]
				PriceClass: 'PriceClass_All'
				HttpVersion: 'http2'
				ViewerCertificate: {
					SslSupportMethod: 'sni-only'
					AcmCertificateArn
				}
				Origins: [ {
					Id: 'S3BucketOrigin'
					DomainName: Select 1, Split '//', GetAtt "#{ ctx.name }S3Bucket", 'WebsiteURL'
					CustomOriginConfig: {
						OriginProtocolPolicy: 'http-only'
					}
				} ]
				DefaultCacheBehavior: {
					TargetOriginId: 'S3BucketOrigin'
					ViewerProtocolPolicy: 'redirect-to-https'
					AllowedMethods: [ 'GET', 'HEAD', 'OPTIONS' ]
					Compress: true
					ForwardedValues: {
						QueryString: false
						Cookies: {
							Forward: 'none'
						}
					}
				}
			}
		}
	}

	# -------------------------------------------------------
	# Make outputs

	output ctx, "#{ ctx.name }DomainName", {
		Name:			"#{ Stack }-#{ ctx.name }-DomainName"
		Value:			DomainName
		Description:	'The Domain Name of the Website'
	}

	output ctx, "#{ ctx.name }DistributionId", {
		Name:			"#{ Stack }-#{ ctx.name }-DistributionId"
		Value:			Ref "#{ ctx.name }CloudFrontDistribution"
		Description:	'The CloudFront Distribution ID of the Website'
	}

	# -------------------------------------------------------
	# Events before stack deploy

	ctx.on 'validate-resource', ->
		folder = ctx.string 'Syncing.Folder'
		folder = path.join process.cwd(), folder

		if not await isDirectory folder
			throw new Error "Website folder doesn't exist: #{ folder }"

	# -------------------------------------------------------
	# Events after stack deploy

	ctx.on 'after-deploying-stack', ->
		region		= ctx.string '@Config.Region'
		profile		= ctx.string '@Config.Profile'
		folder 		= ctx.string 'Syncing.Folder'
		folder		= path.join process.cwd(), folder

		await task(
			"Syncing s3 bucket: #{ BucketName }"
			sync {
				profile
				region
				folder
				bucket:					BucketName
				ignoredExtensions:		ctx.array 'Syncing.IgnoreExtensions', []
				acl:					ctx.string 'ACL', 'public-read'
				cacheAge:				ctx.number 'CacheAge', 31536000
			}
		)

		if ctx.boolean 'Syncing.ClearCache', true
			values			= await fetchExports { profile, region }
			distributionId	= values[ "#{ Stack }-#{ ctx.name }-DistributionId" ]
			if distributionId
				await task(
					"Clearing cloudfront cache: #{ distributionId }"
					clearCache {
						profile
						region
						distributionId
					}
				)

		keyval "#{ ctx.name } URL", "https://#{ DomainName }"
