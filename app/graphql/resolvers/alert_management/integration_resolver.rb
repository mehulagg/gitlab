# frozen_string_literal: true

module Resolvers
  module AlertManagement
    class IntegrationResolver < BaseResolver
      argument :id, ::Types::GlobalIDType,
                required: false,
                description: 'Global ID for an integration'

      alias_method :project, :synchronized_object

      def resolve(**args)
        return [] if project.nil? || !Ability.allowed?(current_user, :admin_operations, project)
        return integration_for_id(args[:id]) if args[:id]

        http_integrations + prometheus_integrations
      end

      private

      def prometheus_integrations
        project.services.by_type('PrometheusService')
      end

      def http_integrations
        ::AlertManagement::HttpIntegrationsFinder.new(project, {}).execute
      end

      def integration_for_id(id)
        gid = GitlabSchema.parse_gid(id)
        return [] unless [::PrometheusService, ::AlertManagement::HttpIntegration].include?(gid.model_class)

        integration = gid.find
        return [] unless integration.project_id == project.id

        [integration]
      end
    end
  end
end
