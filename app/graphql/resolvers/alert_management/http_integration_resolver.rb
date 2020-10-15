# frozen_string_literal: true

module Resolvers
  module AlertManagement
    class HttpIntegrationResolver < BaseResolver
      type Types::AlertManagement::HttpIntegrationType, null: true

      argument :id, GraphQL::STRING_TYPE,
                required: false,
                description: 'ID of the alert. For example, "1"'

      def resolve(**args)
        parent = object.respond_to?(:sync) ? object.sync : object
        return ::AlertManagement::HttpIntegration.none if parent.nil?

        ::AlertManagement::HttpIntegrationsFinder.new(parent, args).execute
      end
    end
  end
end
