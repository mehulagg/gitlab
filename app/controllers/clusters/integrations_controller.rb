# frozen_string_literal: true

module Clusters
  class IntegrationsController < ::Clusters::BaseController
    before_action :cluster
    before_action :authorize_create_cluster!, only: [:create]

    def create
      Clusters::Integrations::CreateService
        .new(container: project, cluster: cluster, current_user: current_user, params: cluster_integration_params)
        .execute
    end

    private

    def cluster_integration_params
      params.require(:integration).permit(:application_type, :enabled)
    end

    def cluster
      @cluster ||= clusterable.clusters.find(params[:cluster_id]).present(current_user: current_user)
    end
  end
end
