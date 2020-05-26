# frozen_string_literal: true

module Deployments
  class FinishedWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    queue_namespace :deployment
    feature_category :continuous_delivery
    worker_resource_boundary :cpu
    tags :no_disk_io

    def perform(deployment_id)
      if (deploy = Deployment.find_by_id(deployment_id))
        LinkMergeRequestsService.new(deploy).execute
        deploy.execute_hooks
      end
    end
  end
end
