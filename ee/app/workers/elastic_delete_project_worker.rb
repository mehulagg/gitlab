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

  def remove_project_and_children_documents(project_id, es_id)
    client.delete_by_query({
      index: Project.__elasticsearch__.index_name,
      routing: es_id,
      body: {
        query: {
          bool: {
            should: [
              {
                has_parent: {
                  parent_type: 'project',
                  query: {
                    term: { id: project_id }
                  }
                }
              },
              {
                term: {
                  _id: es_id
                }
              }
            ]
          }
        }
      }
    })
  end
end
