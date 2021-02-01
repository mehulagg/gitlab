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
        query_hash = basic_query_hash(%w[note], query, count_only: options[:count_only])

        context.name(:note) do
          query_hash = context.name(:authorized) { project_ids_filter(query_hash, options) }
          query_hash = context.name(:confidentiality) { confidentiality_filter(query_hash, options) }
        end

        query_hash[:highlight] = highlight_options(options[:in]) unless options[:count_only]

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
                      _name: context.name(:issue, :not_confidential),
                      should: [
                        { bool: { must_not: [{ exists: { field: :issue } }] } },
                        { term: { "issue.confidential" => false } }
                      ]
                    }
                  },
                  {
                    bool: {
                      _name: context.name(:not_confidential),
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
                      { term: { "issue.confidential" => { _name: context.name(:issue, :confidential), value: true } } },
                      { term: { confidential: { _name: context.name(:confidential), value: true } } }
                    ]
                  }
                },
                {
                  bool: {
                    should: [
                      { term: { "issue.author_id" => { _name: context.name(:as_author), value: current_user.id } } },
                      { term: { "issue.assignee_id" => { _name: context.name(:as_assignee), value: current_user.id } } },
                      { terms: { _name: context.name(:project, :membership, :id), project_id: authorized_project_ids(current_user, options) } }
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

        project_query = context.name(:project) do
          project_ids_query(
            options[:current_user],
            options[:project_ids],
            options[:public_and_internal_projects],
            options[:features]
          )
        end

        filters = {
          bool: {
            _name: context.name,
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
                { term: { noteable_type: { _name: context.name(:noteable, :is_a, noteable_type), value: noteable_type } } }
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
      # We do not implement `no_join_project` argument for notes class yet
      # as this is not supported. This will need to be fixed when we move
      # notes to a new index.
      override :pick_projects_by_membership
      def pick_projects_by_membership(project_ids, user, _, _ = nil)
        noteable_type_to_feature.map do |noteable_type, feature|
          context.name(feature) do
            condition =
              if project_ids == :any
                { term: { visibility_level: { _name: context.name(:any), value: Project::PRIVATE } } }
              else
                { terms: { _name: context.name(:membership, :id), id: filter_ids_by_feature(project_ids, user, feature) } }
              end

            limit =
              { terms: { _name: context.name(:enabled_or_private), "#{feature}_access_level" => [::ProjectFeature::ENABLED, ::ProjectFeature::PRIVATE] } }

            { bool: { _name: context.name, filter: [condition, limit] }, noteable_type: noteable_type }
          end
        end
      end

      # Query notes based on the various feature permission of the noteable_type.
      # Appends `noteable_type` (which will be removed in project_ids_filter)
      # for base model filtering.
      override :limit_by_feature
      def limit_by_feature(condition, _ = nil, include_members_only:)
        noteable_type_to_feature.map do |noteable_type, feature|
          context.name(feature) do
            limit =
              if include_members_only
                { terms: { _name: context.name(:enabled_or_private), "#{feature}_access_level" => [::ProjectFeature::ENABLED, ::ProjectFeature::PRIVATE] } }
              else
                { term: { "#{feature}_access_level" => { _name: context.name(:enabled), value: ::ProjectFeature::ENABLED } } }
              end

            { bool: { _name: context.name, filter: [condition, limit] }, noteable_type: noteable_type }
          end
        end
      end
    end
  end
end
