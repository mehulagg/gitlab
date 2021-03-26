# frozen_string_literal: true

module Resolvers
  module AlertManagement
    class IntegrationsResolver < BaseResolver
      alias_method :project, :object

      SUPPORTED_INTEGRATIONS = [::PrometheusService, ::AlertManagement::HttpIntegration].freeze

      # Cannot use a specific GlobalIDType. ID can be one of two types:
      # `AlertManagement::HttpIntegration` or `PrometheusService`
      #
      # rubocop:disable Graphql/IDType
      argument :id, GraphQL::ID_TYPE,
               required: false,
               description: 'ID of the integration.'
      # rubocop:enable Graphql/IDType

      type Types::AlertManagement::IntegrationType.connection_type, null: true

      def resolve(**args)
        if args[:id]
          [integration_by(gid: args[:id])]
        else
          http_integrations + prometheus_integrations
        end
      end

      private

      def integration_by(gid:)
        # Expected type is unknown. Can be either `AlertManagement::HttpIntegration` or `PrometheusService`
        integration = GitlabSchema.object_from_id(gid)&.sync # rubocop:disable Graphql/GIDExpectedType

        return unless integration
        return unless integration.class.in?(SUPPORTED_INTEGRATIONS)
        return if integration.is_a?(::PrometheusService) && !prometheus_integrations_allowed?
        return if integration.is_a?(::AlertManagement::HttpIntegration) && !http_integrations_allowed?
        return if project != integration.project

        integration
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
    end
  end
end
