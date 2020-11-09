# frozen_string_literal: true

module Environments
  class AutoRollbackWorker
    include ApplicationWorker

    idempotent!
    feature_category :continuous_delivery

    def perform(environment_id)
      Environment.find_by_id(environment_id).try do |environment|
        Environments::AutoRollbackService
          .new(environment.project, nil)
          .execute
      end
    end
  end
end
