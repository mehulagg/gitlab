# frozen_string_literal: true

module Environments
  module CanaryIngress
    class PatchWorker
      include ApplicationWorker

      sidekiq_options retry: false
      idempotent!
      worker_has_external_dependencies!
      feature_category :continuous_delivery

      def perform(environment_id, params)
        Environment.find_by_id(environment_id).try do |environment|
          Environments::CanaryIngress::PatchService
            .new(environment.project, nil, params)
            .execute(environment)
        end
      end
    end
  end
end
