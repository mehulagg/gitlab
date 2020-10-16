# frozen_string_literal: true

module Resolvers
  module AlertManagement
    class IntegrationResolver < BaseResolver
      argument :id, GraphQL::ID_TYPE,
                required: false,
                description: 'ID of the integration'

      argument :type, GraphQL::STRING_TYPE,
                required: false,
                description: 'Type of integration'

      alias_method :project, :synchronized_object

      def resolve(**args)
        return ::AlertManagement::HttpIntegration.none if project.nil?

        http_integrations(project, args) + prometheus_integrations(project, args)
      end

      private

      def prometheus_integrations(project, args)
        return [] unless args[:id].nil?
        return [] unless args[:type] == 'PROMETHEUS' || args[:type].nil?

        project.services.by_type('PrometheusService')
      end

      def http_integrations(project, args)
        return [] unless args[:type] == 'HTTP' || args[:type].nil?

        ::AlertManagement::HttpIntegrationsFinder.new(current_user, project, args).execute
      end
    end
  end
end
