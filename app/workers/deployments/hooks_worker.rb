# frozen_string_literal: true

module Deployments
  class HooksWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    queue_namespace :deployment
    feature_category :continuous_delivery
    worker_resource_boundary :cpu

    def perform(params = {})
      if (deploy = Deployment.find_by_id(params[:deployment_id]))
        deploy.execute_hooks(params[:status_changed_at])
      end
    end
  end
end
