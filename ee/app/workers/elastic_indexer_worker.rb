# frozen_string_literal: true

# Usage of this worker is deprecated, please remove it in the next major version
class ElasticIndexerWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  sidekiq_options retry: 2
  feature_category :global_search
  urgency :throttled
  loggable_arguments 0, 1, 4

  def perform(operation, class_name, record_id, es_id, options = {})
    return true unless Gitlab::CurrentSettings.elasticsearch_indexing?

    klass = class_name.constantize
    record = klass.find(record_id)

    case operation.to_s
    when /index/
      record.maintain_elasticsearch_create
    when /update/
      record.maintain_elasticsearch_update
    when /delete/
      record.maintain_elasticsearch_destroy
    end
  end
end
