# frozen_string_literal: true

class ElasticCommitIndexerWorker
  include ApplicationWorker
  prepend Elastic::IndexingControl
  include Gitlab::ExclusiveLeaseHelpers

  feature_category :global_search
  sidekiq_options retry: 2
  urgency :throttled
  idempotent!
  loggable_arguments 1, 2, 3

  # Performs the commits and blobs indexation
  #
  # project_id - The ID of the project to index
  # oldrev @deprecated - The revision to start indexing at (default: INDEXED_SHA)
  # newrev @deprecated - The revision to stop indexing at (default: HEAD)
  # wiki - Treat this project as a Wiki
  #
  # The indexation will cover all commits within INDEXED_SHA..HEAD
  def perform(project_id, oldrev = nil, newrev = nil, wiki = false)
    return true unless Gitlab::CurrentSettings.elasticsearch_indexing?

    project = Project.find(project_id)
    return true unless project.use_elasticsearch?

    in_lock("#{self.class.name}/#{project_id}/#{wiki}", ttl: 1.hour, retries: 0) do
      Gitlab::Elastic::Indexer.new(project, wiki: wiki).run
    end
  end
end
