
import resource from '../../feature/resource'

keySchema = (schema) -> {
	KeySchema: schema.map (item) -> {
		AttributeName:	String item.Name
		KeyType:		String item.Type
	}
}

provisionedIndex = (ctx, index) ->
	mode = ctx.string 'BillingMode', 'PAY_PER_REQUEST'
	if mode isnt 'PROVISIONED'
		return {}

	return {
		ProvisionedThroughput: {
			ReadCapacityUnits:	ctx.number "Indexes.#{ index }.RCU", 1
			WriteCapacityUnits: ctx.number 'WCU', 1
		}
	}

indexes = (ctx) ->
	indexes = ctx.array 'Indexes', []

	return {
		GlobalSecondaryIndexes: indexes.map (_, index) => {
			IndexName: ctx.string "Indexes.#{ index }.IndexName"
			...keySchema ctx.array "Indexes.#{ index }.KeySchema"
			...provisionedIndex ctx, index

			Projection: {
				ProjectionType: ctx.string "Indexes.#{ index }.Projection", 'ALL'
			}
		}
	}

ttl = (ctx) ->
	attribute = ctx.string 'TTL', ''
	if not attribute
		return {}

	return {
		TimeToLiveSpecification: {
			AttributeName: attribute
			Enabled: true
		}
	}

billing = (ctx) ->
	mode = ctx.string 'BillingMode', 'PAY_PER_REQUEST'
	return switch mode
		when 'PAY_PER_REQUEST' then {
			BillingMode: 'PAY_PER_REQUEST'
		}

		when 'PROVISIONED' then {
			BillingMode: 'PROVISIONED'
			ProvisionedThroughput: {
				ReadCapacityUnits:	ctx.number 'RCU', 1
				WriteCapacityUnits: ctx.number 'WCU', 1
			}
		}

attributeDefinitions = (ctx) -> {
	AttributeDefinitions: ctx.array('AttributeDefinitions').map (_, index) -> {
		AttributeName: ctx.string "AttributeDefinitions.#{ index }.Name"
		AttributeType: ctx.string "AttributeDefinitions.#{ index }.Type"
	}
}

pointInTimeRecovery = (ctx) ->
	enabled = ctx.boolean 'PointInTimeRecovery', false
	if not enabled
		return {}

	return {
		PointInTimeRecoverySpecification: {
			PointInTimeRecoveryEnabled: true
		}
	}

stream = (ctx) ->
	stream = ctx.string 'Stream', ''
	if not stream
		return {}

	return {
		StreamSpecification: {
			StreamViewType: stream
		}
	}

export default resource (ctx) ->
	ctx.addResource ctx.name, {
		Type: 'AWS::DynamoDB::Table'
		DeletionPolicy: ctx.string 'DeletionPolicy', 'Delete'
		Properties: {
			TableName: ctx.string 'TableName'
			...keySchema ctx.array 'KeySchema'
			...billing ctx
			...attributeDefinitions ctx
			...pointInTimeRecovery ctx
			...ttl ctx
			...stream ctx
			...indexes ctx
			Tags: [
				...ctx.array 'Tags', []
				{ Key: 'TableName', Value: ctx.string 'TableName' }
			]
		}
	}
