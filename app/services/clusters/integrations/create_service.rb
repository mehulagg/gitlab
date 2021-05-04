# frozen_string_literal: true

module Clusters
  module Integrations
    class CreateService < BaseContainerService
      attr_accessor :cluster

      def initialize(container:, cluster:, current_user: nil, params: {})
        @cluster = cluster

        super(container: container, current_user: current_user, params: params)
      end

      def execute
        return ServiceResponse.error(message: 'Unauthorized') unless authorized?

        integrations = []
        ApplicationRecord.transaction do
          integrations << cluster.find_or_build_integration_prometheus.update!(enabled: params[:prometheus_enabled])
          integrations << cluster.find_or_build_integration_elastic_stack.update!(enabled: params[:elastic_stack_enabled])
        end

        ServiceResponse.success(message: s_('ClusterIntegration|Integrations updated'), payload: { integrations: integrations })
      end

      private

      def authorized?
        Ability.allowed?(current_user, :admin_cluster, cluster)
      end
    end
  end
end
