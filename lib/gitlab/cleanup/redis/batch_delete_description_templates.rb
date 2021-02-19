# frozen_string_literal: true

module Gitlab
  module Cleanup
    module Redis
      class BatchDeleteDescriptionTemplates < BatchDeleteByPattern
        attr_reader :project_ids

        def initialize(project_ids = [])
          @project_ids = project_ids

          patterns = compute_patterns(project_ids)
          super(patterns)
        end

        private

        def compute_patterns(project_ids)
          cache_key_patterns = []

          if project_ids.blank?
            cache_key_patterns = %W[
              #{Gitlab::Redis::Cache::CACHE_NAMESPACE}:issue_template_names_by_category:*
              #{Gitlab::Redis::Cache::CACHE_NAMESPACE}:merge_request_template_names_by_category:*
            ]
          else
            Project.id_in(project_ids).each_batch do |batch|
              cache_key_patterns << batch.map do |pr|
                next unless pr.repository.exists?

                cache = Gitlab::RepositoryCache.new(pr.repository)
                %W[
                  #{Gitlab::Redis::Cache::CACHE_NAMESPACE}:#{cache&.cache_key(:issue_template_names_by_category)}
                  #{Gitlab::Redis::Cache::CACHE_NAMESPACE}:#{cache&.cache_key(:merge_request_template_names_by_category)}
                ]
              end
            end
          end

          cache_key_patterns.flatten.compact
        end
      end
    end
  end
end
