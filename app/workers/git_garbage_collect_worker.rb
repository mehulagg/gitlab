# frozen_string_literal: true

class GitGarbageCollectWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  sidekiq_options retry: false
  feature_category :gitaly
  loggable_arguments 1, 2, 3

  def perform(resource_id, task = :gc, lease_key = nil, lease_uuid = nil)
    Projects::GitGarbageCollectWorker.perform(resource_id, task, lease_key, lease_uid)
  end
end
