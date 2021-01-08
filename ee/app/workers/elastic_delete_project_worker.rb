# frozen_string_literal: true

class ElasticDeleteProjectWorker
  include ApplicationWorker
  include Elasticsearch::Model::Client::ClassMethods
  prepend Elastic::IndexingControl

  sidekiq_options retry: 2
  feature_category :global_search
  urgency :throttled
  idempotent!

  def perform(project_id, es_id)
    remove_project_and_children_documents(project_id, es_id)
  end

  private

  def indices
    helper = Gitlab::Elastic::Helper.default

    if Elastic::DataMigrationService.migration_has_finished?(:migrate_issues_to_separate_index)
      [helper.target_name] + helper.standalone_indices_proxies.map(&:index_name)
    else
      [helper.target_name]
    end
  end

  def remove_project_and_children_documents(project_id, es_id)
    client.delete_by_query({
      index: indices,
      routing: es_id,
      body: {
        query: {
          bool: {
            should: [
              {
                term: {
                  _id: es_id
                }
              },
              {
                term: {
                  project_id: project_id
                }
              },
              {
                term: {
                  target_project_id: project_id # handle merge_request which aliases project_id to target_project_id
                }
              }
            ]
          }
        }
      }
    })
  end
end
