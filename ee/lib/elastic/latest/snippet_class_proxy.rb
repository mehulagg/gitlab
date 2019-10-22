# frozen_string_literal: true

module Elastic
  module Latest
    class SnippetClassProxy < ApplicationClassProxy
      def elastic_search(query, options: {})
        query_hash = basic_query_hash(%w(title file_name), query)
        query_hash = filter(query_hash, options)

        search(query_hash)
      end

      def elastic_search_code(query, options: {})
        query_hash = basic_query_hash(%w(content), query)
        query_hash = filter(query_hash, options)

        search(query_hash)
      end

      def es_type
        target.base_class.name.underscore
      end

      private

      def filter(query_hash, options)
        user = options[:current_user]
        return query_hash if user&.full_private_access?

        filter_conditions =
          filter_personal_snippets(user, options) +
          filter_project_snippets(user, options)

        # Match any of the filter conditions, in addition to the existing conditions
        query_hash[:query][:bool][:filter] << {
          bool: {
            should: filter_conditions
          }
        }

        query_hash
      end

      def filter_personal_snippets(user, options)
        filter_conditions = []

        # Include accessible personal snippets
        filter_conditions << {
          bool: {
            filter: [
              { terms: { visibility_level: Gitlab::VisibilityLevel.levels_for_user(user) } }
            ],
            must_not: { exists: { field: 'project_id' } }
          }
        }

        # Include authored personal snippets
        if user
          filter_conditions << {
            bool: {
              filter: [
                { term: { author_id: user.id } }
              ],
              must_not: { exists: { field: 'project_id' } }
            }
          }
        end

        filter_conditions
      end

      def filter_project_snippets(user, options)
        return [] unless Ability.allowed?(user, :read_cross_project)

        filter_conditions = []

        # Include public/internal project snippets for accessible projects
        filter_conditions << {
          bool: {
            filter: [
              { terms: { visibility_level: Gitlab::VisibilityLevel.levels_for_user(user) } },
              {
                has_parent: {
                  parent_type: 'project',
                  query: {
                    bool: project_ids_query(
                      user,
                      options[:project_ids],
                      options[:public_and_internal_projects],
                      'snippets'
                    )
                  }
                }
              }
            ]
          }
        }

        # Include all project snippets for authorized projects
        if user
          filter_conditions << {
            bool: {
              must: [
                { terms: { project_id: user.authorized_projects(Gitlab::Access::GUEST).pluck_primary_key } }
              ]
            }
          }
        end

        filter_conditions
      end
    end
  end
end
