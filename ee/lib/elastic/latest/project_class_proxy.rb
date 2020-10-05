# frozen_string_literal: true

module Elastic
  module Latest
    class ProjectClassProxy < ApplicationClassProxy
      def elastic_search(query, options: {})
        options[:in] = %w(name^10 name_with_namespace^2 path_with_namespace path^9 description)

        query_hash = basic_query_hash(options[:in], query)

        filters = [{ terms: { type: [es_type] } }]

        if options[:namespace_id]
          filters << {
            terms: {
              namespace_id: [options[:namespace_id]].flatten
            }
          }
        end

        if options[:non_archived]
          filters << {
            terms: {
              archived: [!options[:non_archived]].flatten
            }
          }
        end

        if options[:visibility_levels]
          filters << {
            terms: {
              visibility_level: [options[:visibility_levels]].flatten
            }
          }
        end

        if options[:project_ids]
          filters << {
            bool: project_ids_query(options[:current_user], options[:project_ids], options[:public_and_internal_projects])
          }
        end

        query_hash[:query][:bool][:filter] = filters

        search(query_hash, options)
      end
    end
  end
end
