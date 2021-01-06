# frozen_string_literal: true

Rails.application.configure do |config|
  # ApolloUploadServer::Middleware expects to find uploaded files ready to use
  config.middleware.insert_before(ApolloUploadServer::Middleware, Gitlab::Middleware::Multipart)
end

GraphQL::ObjectType.accepts_definitions(authorize: GraphQL::Define.assign_metadata_key(:authorize))
GraphQL::Field.accepts_definitions(authorize: GraphQL::Define.assign_metadata_key(:authorize))

GraphQL::Schema::Object.accepts_definition(:authorize)
GraphQL::Schema::Field.accepts_definition(:authorize)
