# frozen_string_literal: true

class ElasticAssociationIndexerWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker

  feature_category :global_search
  loggable_arguments 0, 2

  def perform(class_name, id, indexed_associations)
    return unless Gitlab::CurrentSettings.elasticsearch_indexing?

    klass = class_name.constantize
    object = klass.find(id)
    return unless object.use_elasticsearch?

    Elastic::ProcessBookkeepingService.maintain_indexed_associations(object, indexed_associations)
  end
end
