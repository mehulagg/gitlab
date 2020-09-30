# frozen_string_literal: true

module Elastic
  module Latest
    class ApplicationClassProxy < Elasticsearch::Model::Proxy::ClassMethodsProxy
      include ClassProxyUtil
      include Elastic::Latest::Routing

      def search(query, search_options = {})
        es_options = routing_options(search_options)

        # Calling elasticsearch-ruby method
        super(query, es_options)
      end

      def es_type
        target.name.underscore
      end

      def es_import(**options)
        transform = lambda do |r|
          proxy = r.__elasticsearch__.version(version_namespace)

          { index: { _id: proxy.es_id, data: proxy.as_indexed_json } }.tap do |data|
            data[:index][:routing] = proxy.es_parent if proxy.es_parent
          end
        end

        options[:transform] = transform

        self.import(options)
      end

      private

      def default_operator
        return :or if Feature.enabled?(:elasticsearch_use_or_default_operator)

        :and
      end

      def highlight_options(fields)
        es_fields = fields.map { |field| field.split('^').first }.each_with_object({}) do |field, memo|
          memo[field.to_sym] = {}
        end

        { fields: es_fields }
      end

      def basic_query_hash(fields, query)
        query_hash =
          if query.present?
            {
              query: {
                bool: {
                  must: [{
                    simple_query_string: {
                      fields: fields,
                      query: query,
                      default_operator: default_operator
                    }
                  }],
                  filter: [{
                    term: { type: self.es_type }
                  }]
                }
              }
            }
          else
            {
              query: {
                bool: {
                  must: { match_all: {} }
                }
              },
              track_scores: true
            }
          end

        query_hash[:highlight] = highlight_options(fields)

        query_hash
      end

      def iid_query_hash(iid)
        {
          query: {
            bool: {
              filter: [
                { term: { iid: iid } },
                { term: { type: self.es_type } }
              ]
            }
          }
        }
      end

      # Builds an elasticsearch query that will select child documents from a
      # set of projects, taking user access rules into account.
      def project_ids_filter(query_hash, options)
        project_query = project_ids_query(
          options[:current_user],
          options[:project_ids],
          options[:public_and_internal_projects],
          options[:features]
        )

        query_hash[:query][:bool][:filter] ||= []
        query_hash[:query][:bool][:filter] << {
          has_parent: {
            parent_type: "project",
            query: {
              bool: project_query
            }
          }
        }

        query_hash
      end

      # Builds an elasticsearch query that will select projects the user is
      # granted access to.
      #
      # If a project feature(s) is specified, it indicates interest in child
      # documents gated by that project feature - e.g., "issues". The feature's
      # visibility level must be taken into account.
      def project_ids_query(user, project_ids, public_and_internal_projects, features = nil)
        scoped_project_ids = scoped_project_ids(user, project_ids)

        # At least one condition must be present, so pick no projects for
        # anonymous users.
        # Pick private, internal and public projects the user is a member of.
        # Pick all private projects for admins & auditors.
        conditions = pick_projects_by_membership(scoped_project_ids, user, features)

        if public_and_internal_projects
          # Skip internal projects for anonymous and external users.
          # Others are given access to all internal projects.
          #
          # Admins & auditors get access to internal projects even
          # if the feature is private.
          conditions += pick_projects_by_visibility(Project::INTERNAL, user, features) if user && !user.external?

          # All users, including anonymous, can access public projects.
          # Admins & auditors get access to public projects where the feature is
          # private.
          conditions += pick_projects_by_visibility(Project::PUBLIC, user, features)
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
      def pick_projects_by_membership(project_ids, user, features = nil)
        if features.nil?
          if project_ids == :any
            return [{ term: { visibility_level: Project::PRIVATE } }]
          else
            return [{ terms: { id: project_ids } }]
          end
        end

        Array(features).map do |feature|
          condition =
            if project_ids == :any
              { term: { visibility_level: Project::PRIVATE } }
            else
              { terms: { id: filter_ids_by_feature(project_ids, user, feature) } }
            end

          limit =
            { terms: { "#{feature}_access_level" => [::ProjectFeature::ENABLED, ::ProjectFeature::PRIVATE] } }

          { bool: { filter: [condition, limit] } }
        end
      end

      # Grant access to projects of the specified visibility level to the user.
      #
      # If a project feature is specified, access is only granted if the feature
      # is enabled or, for admins & auditors, private.
      def pick_projects_by_visibility(visibility, user, features)
        condition = { term: { visibility_level: visibility } }

        limit_by_feature(condition, features, include_members_only: user&.can_read_all_resources?)
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

        features = Array(features)

        features.map do |feature|
          limit =
            if include_members_only
              { terms: { "#{feature}_access_level" => [::ProjectFeature::ENABLED, ::ProjectFeature::PRIVATE] } }
            else
              { term: { "#{feature}_access_level" => ::ProjectFeature::ENABLED } }
            end

          { bool: { filter: [condition, limit] } }
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
    end
  end
end
