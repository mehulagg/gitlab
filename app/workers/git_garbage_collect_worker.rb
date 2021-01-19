# frozen_string_literal: true

# According to our docs, we can only remove workers on major releases
# https://docs.gitlab.com/ee/development/sidekiq_style_guide.html#removing-workers.
#
# So we need to still maintainer this until 14.0 but with the current functionality.
class GitGarbageCollectWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  sidekiq_options retry: false
  feature_category :gitaly
  loggable_arguments 1, 2, 3

  def perform(resource_id, task = :gc, lease_key = nil, lease_uuid = nil)
    Projects::GitGarbageCollectWorker.new.perform(resource_id, task, lease_key, lease_uuid)
  end
end
