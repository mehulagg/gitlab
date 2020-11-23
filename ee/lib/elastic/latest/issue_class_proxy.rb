# frozen_string_literal: true

module Elastic
  module Latest
    class IssueClassProxy < ApplicationClassProxy
      include StateFilter

      def elastic_search(query, options: {})
        query_hash =
          if query =~ /#(\d+)\z/
            iid_query_hash(Regexp.last_match(1))
          else
            fields = %w(title^2 description)

            # We can only allow searching the iid field if the query is
            # just a number, otherwise Elasticsearch will error since this
            # field is type integer.
            fields << "iid^3" if query =~ /\A\d+\z/

            basic_query_hash(fields, query)
          end

        options[:features] = 'issues'
        context.name(:issue) do
          query_hash = context.name(:authorized) { project_ids_filter(query_hash, options) }
          query_hash = context.name(:confidentiality) { confidentiality_filter(query_hash, options) }
          query_hash = context.name(:match) { state_filter(query_hash, options) }
        end
        query_hash = apply_sort(query_hash, options)

        search(query_hash, options)
      end

      private

      # Builds an elasticsearch query that will select documents from a
      # set of projects for Group and Project searches, taking user access
      # rules for issues into account. Relies upon super for Global searches
      def project_ids_filter(query_hash, options)
        return public_and_internal_issues_filter(query_hash, options) if options[:public_and_internal_projects]

        current_user = options[:current_user]
        scoped_project_ids = scoped_project_ids(current_user, options[:project_ids])
        return public_and_internal_issues_filter if scoped_project_ids == :any

        context.name(:project) do
          query_hash[:query][:bool][:filter] ||= []
          query_hash[:query][:bool][:filter] << {
            terms: {
              _name: context.name,
              project_id: filter_ids_by_feature(scoped_project_ids, current_user, 'issues')
            }
          }
        end

        query_hash
      end

      def public_and_internal_issues_filter(query_hash, options)
        context.name(:project) do
          project_query = project_ids_query(
            options[:current_user],
            options[:project_ids],
            options[:public_and_internal_projects],
          )

          query_hash[:query][:bool][:filter] ||= []
          query_hash[:query][:bool][:filter] << {
            query: {
              bool: project_query
            }
          }
        end

        query_hash
      end

      # Builds an elasticsearch query that will select projects the user is
      # granted access to.
      #
      # If a project feature(s) is specified, it indicates interest in child
      # documents gated by that project feature - e.g., "issues". The feature's
      # visibility level must be taken into account.
      def project_ids_query(user, project_ids, public_and_internal_projects)
        scoped_project_ids = scoped_project_ids(user, project_ids)

        # At least one condition must be present, so pick no projects for
        # anonymous users.
        # Pick private, internal and public projects the user is a member of.
        # Pick all private projects for admins & auditors.
        conditions = pick_projects_by_membership(scoped_project_ids, user)

        if public_and_internal_projects
          context.name(:visibility) do
            # Skip internal projects for anonymous and external users.
            # Others are given access to all internal projects.
            #
            # Admins & auditors get access to internal projects even
            # if the feature is private.
            conditions += pick_projects_by_visibility(Project::INTERNAL, user) if user && !user.external?

            # All users, including anonymous, can access public projects.
            # Admins & auditors get access to public projects where the feature is
            # private.
            conditions += pick_projects_by_visibility(Project::PUBLIC, user)
          end
        end

        { should: conditions }
      end

      # Most users come with a list of projects they are members of, which may
      # be a mix of public, internal or private. Grant access to them all, as
      # long as the project feature is not disabled.
      #
      # Admins & auditors are given access to all private projects. Access to
      # internal or public projects where the project feature is private is not
      # granted here.
      def pick_projects_by_membership(project_ids, user)
        condition =
          if project_ids == :any
            [bool: {
              filter: {
                term: { issues_acces_level: { _name: context.name(:any), value: Project::PRIVATE }}}}]
          else
            condition = { terms: { _name: context.name(:membership, :id), id: filter_ids_by_feature(project_ids, user, feature) } }
            limit = {
              terms: {
                _name: context.name(feature, :enabled_or_private),
                "issues_access_level" => [::ProjectFeature::ENABLED, ::ProjectFeature::PRIVATE]
              }
            }

            [{
              bool: {
                filter: [condition, limit]}}]
          end
      end

      # Grant access to projects of the specified visibility level to the user.
      #
      # If a project feature is specified, access is only granted if the feature
      # is enabled or, for admins & auditors, private.
      def pick_projects_by_visibility(visibility, user)
        context.name(visibility) do
          condition = { term: { issues_access_level: { _name: context.name, value: visibility } } }

          limit_by_feature(condition, include_members_only: user&.can_read_all_resources?)
        end
      end

      # If a project feature(s) is specified, access is dependent on its visibility
      # level being enabled (or private if `include_members_only: true`).
      #
      # This method is a no-op if no project feature is specified.
      # It accepts an array of features or a single feature, when an array is provided
      # it queries if any of the features is enabled.
      #
      # Always denies access to projects when the features are disabled - even to
      # admins & auditors - as stale child documents may be present.
      def limit_by_feature(condition, features, include_members_only:)
        return [condition] unless features

        context.name(:issues, :access_level) do
          limit =
            if include_members_only
              {
                terms: {
                  _name: context.name(:enabled_or_private),
                  "issues_access_level" => [::ProjectFeature::ENABLED, ::ProjectFeature::PRIVATE]
                }
              }
            else
              {
                term: {
                  "issues_access_level" => {
                    _name: context.name(:enabled),
                    value: ::ProjectFeature::ENABLED
                  }
                }
              }
            end

          [{
            bool: {
              _name: context.name,
              filter: [condition, limit]
            }
          }]
        end
      end

      def filter_ids_by_feature(project_ids, user, feature)
        Project
          .id_in(project_ids)
          .filter_by_feature_visibility(feature, user)
          .pluck_primary_key
      end

      def scoped_project_ids(current_user, project_ids)
        return :any if project_ids == :any

        project_ids ||= []

        # When reading cross project is not allowed, only allow searching a
        # a single project, so the `:read_*` ability is only checked once.
        unless Ability.allowed?(current_user, :read_cross_project)
          return [] if project_ids.size > 1
        end

        project_ids
      end

      def authorized_project_ids(current_user, options = {})
        return [] unless current_user

        scoped_project_ids = scoped_project_ids(current_user, options[:project_ids])
        authorized_project_ids = current_user.authorized_projects(Gitlab::Access::REPORTER).pluck_primary_key.to_set

        # if the current search is limited to a subset of projects, we should do
        # confidentiality check for these projects.
        authorized_project_ids &= scoped_project_ids.to_set unless scoped_project_ids == :any

        authorized_project_ids.to_a
      end

      def confidentiality_filter(query_hash, options)
        current_user = options[:current_user]
        project_ids = options[:project_ids]

        if [true, false].include?(options[:confidential])
          query_hash[:query][:bool][:filter] << { term: { confidential: options[:confidential] } }
        end

        return query_hash if current_user&.can_read_all_resources?

        scoped_project_ids = scoped_project_ids(current_user, project_ids)
        authorized_project_ids = authorized_project_ids(current_user, options)

        # we can shortcut the filter if the user is authorized to see
        # all the projects for which this query is scoped on
        unless scoped_project_ids == :any || scoped_project_ids.empty?
          return query_hash if authorized_project_ids.to_set == scoped_project_ids.to_set
        end

        filter = { term: { confidential: { _name: context.name(:non_confidential), value: false } } }

        if current_user
          filter = {
              bool: {
                should: [
                  { term: { confidential: { _name: context.name(:non_confidential), value: false } } },
                  {
                    bool: {
                      must: [
                        { term: { confidential: true } },
                        {
                          bool: {
                            should: [
                              { term: { author_id: { _name: context.name(:as_author), value: current_user.id } } },
                              { term: { assignee_id: { _name: context.name(:as_assignee), value: current_user.id } } },
                              { terms: { _name: context.name(:project, :membership, :id), project_id: authorized_project_ids } }
                            ]
                          }
                        }
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
    end
  end
end
