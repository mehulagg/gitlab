# frozen_string_literal: true

module Elastic
  module Latest
    class NoteClassProxy < ApplicationClassProxy
      extend ::Gitlab::Utils::Override

      def es_type
        'note'
      end

      def elastic_search(query, options: {})
        options[:in] = ['note']

        query_hash = basic_query_hash(%w[note], query)
        query_hash = project_ids_filter(query_hash, options)
        query_hash = confidentiality_filter(query_hash, options)

        query_hash[:highlight] = highlight_options(options[:in])

        search(query_hash, options)
      end

      private

      def confidentiality_filter(query_hash, options)
        current_user = options[:current_user]

        return query_hash if current_user&.can_read_all_resources?

        filter = {
          bool: {
            should: [
              bool: {
                must: [
                  {
                    bool: {
                    should: [
                      { bool: { must_not: [{ exists: { field: :issue } }] } },
                      { term: { "issue.confidential" => false } }
                    ]
                    }
                  },
                  {
                    bool: {
                    should: [
                      { bool: { must_not: [{ exists: { field: :confidential } }] } },
                      { term: { confidential: false } }
                    ]
                    }
                  }
                ]
              }
            ]
          }
        }

        if current_user
          filter[:bool][:should] << {
            bool: {
              must: [
                {
                  bool: {
                    should: [
                      { term: { "issue.confidential" => true } },
                      { term: { confidential: true } }
                    ]
                  }
                },
                {
                  bool: {
                    should: [
                      { term: { "issue.author_id" => current_user.id } },
                      { term: { "issue.assignee_id" => current_user.id } },
                      { terms: { project_id: authorized_project_ids(current_user, options) } }
                    ]
                  }
                }
              ]
            }
          }
        end

        query_hash[:query][:bool][:filter] << filter
        query_hash
      end

      def noteable_type_to_feature
        {
          'Issue': :issues,
          'MergeRequest': :merge_requests,
          'Snippet': :snippets,
          'Commit': :repository
        }
      end

      override :project_ids_filter
      def project_ids_filter(query_hash, options)
        query_hash[:query][:bool][:filter] ||= []

        project_query = project_ids_query(
          options[:current_user],
          options[:project_ids],
          options[:public_and_internal_projects],
          options[:features]
        )

        filters = {
          bool: {
            should: []
          }
        }

        # For each project id filter,
        # extract the noteable_type attribute,
        # and use that to filter at Note level.
        project_query[:should].flatten.each do |condition|
          noteable_type = condition.delete(:noteable_type).to_s

          filters[:bool][:should] << {
            bool: {
              must: [
                {
                  has_parent: {
                    parent_type: "project",
                    query: {
                      bool: {
                        should: condition
                      }
                    }
                  }
                },
                { term: { noteable_type: noteable_type } }
              ]
            }
          }
        end

        query_hash[:query][:bool][:filter] << filters
        query_hash
      end

      # Query notes based on the various feature permission of the noteable_type.
      # Appends `noteable_type` (which will be removed in project_ids_filter)
      # for base model filtering.
      override :pick_projects_by_membership
      def pick_projects_by_membership(project_ids, user, _ = nil)
        noteable_type_to_feature.map do |noteable_type, feature|
          condition =
            if project_ids == :any
              { term: { visibility_level: Project::PRIVATE } }
            else
              { terms: { id: filter_ids_by_feature(project_ids, user, feature) } }
            end

          limit =
            { terms: { "#{feature}_access_level" => [::ProjectFeature::ENABLED, ::ProjectFeature::PRIVATE] } }

          { bool: { filter: [condition, limit] }, noteable_type: noteable_type }
        end
      end

      # Query notes based on the various feature permission of the noteable_type.
      # Appends `noteable_type` (which will be removed in project_ids_filter)
      # for base model filtering.
      override :limit_by_feature
      def limit_by_feature(condition, _ = nil, include_members_only:)
        noteable_type_to_feature.map do |noteable_type, feature|
          limit =
            if include_members_only
              { terms: { "#{feature}_access_level" => [::ProjectFeature::ENABLED, ::ProjectFeature::PRIVATE] } }
            else
              { term: { "#{feature}_access_level" => ::ProjectFeature::ENABLED } }
            end

          { bool: { filter: [condition, limit] }, noteable_type: noteable_type }
        end
      end
    end
  end
end
