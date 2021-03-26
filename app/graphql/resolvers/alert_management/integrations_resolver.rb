# frozen_string_literal: true

module Resolvers
  module AlertManagement
    class IntegrationsResolver < BaseResolver
      alias_method :project, :object

      argument :id, ::Types::GlobalIDType,
               required: false,
               description: 'ID of the integration.'

      type Types::AlertManagement::IntegrationType.connection_type, null: true

      def resolve(id: nil)
        if id
          [integration_by(gid: id)]
        else
          http_integrations + prometheus_integrations
        end
      end

      private

      def integration_by(gid:)
        # Expected type is unknown. Can be either `AlertManagement::HttpIntegration` or `PrometheusService`
        integration = GitlabSchema.object_from_id(gid)&.sync # rubocop:disable Graphql/GIDExpectedType

        integration if integration&.class.in?(expected_integration_types) && project == integration&.project
      end

      def prometheus_integrations
        return [] unless prometheus_integrations_allowed?

        Array(project.prometheus_service)
      end

      def http_integrations
        return [] unless http_integrations_allowed?

        ::AlertManagement::HttpIntegrationsFinder.new(project, {}).execute
      end

      def prometheus_integrations_allowed?
        Ability.allowed?(current_user, :admin_project, project)
      end

      def http_integrations_allowed?
        Ability.allowed?(current_user, :admin_operations, project)
      end

      def expected_integration_types
        [].tap do |types|
          types << ::AlertManagement::HttpIntegration if http_integrations_allowed?
          types << ::PrometheusService if prometheus_integrations_allowed?
        end
      end
    end
  end
end
