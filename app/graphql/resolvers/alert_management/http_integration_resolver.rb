# frozen_string_literal: true

module Resolvers
  module AlertManagement
    class HttpIntegrationResolver < BaseResolver
      type Types::AlertManagement::HttpIntegrationType, null: true

      argument :id, GraphQL::ID_TYPE,
                required: false,
                description: 'ID of the integration'

      def resolve(**args)
        parent = object.respond_to?(:sync) ? object.sync : object

        return ::AlertManagement::HttpIntegration.none if parent.nil?

        ::AlertManagement::HttpIntegrationsFinder.new(context[:current_user], parent, args).execute
      end
    end
  end
end
