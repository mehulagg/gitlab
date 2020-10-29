# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Every API endpoint' do
  context 'feature categories' do
    let_it_be(:feature_categories) do
      YAML.load_file(Rails.root.join('config', 'feature_categories.yml')).map(&:to_sym).to_set
    end

    let_it_be(:api_endpoints) do
      API::API.routes.map do |route|
        [route.app.options[:for], API::Base.path_for_app(route.app)]
      end
    end

    let_it_be(:routes_without_category) do
      api_endpoints.map do |(klass, path)|
        next if klass.try(:feature_category_for_action, path)

        # We'll add the rest in https://gitlab.com/gitlab-com/gl-infra/scalability/-/issues/463
        completed_classes = [
          ::API::Users, ::API::Issues, ::API::AccessRequests, ::API::Admin::Ci::Variables,
          ::API::Admin::InstanceClusters, ::API::Admin::Sidekiq, ::API::Appearance,
          ::API::Applications, ::API::Avatar, ::API::AwardEmoji, API::Badges,
          ::API::Boards, ::API::Branches, ::API::BroadcastMessages, ::API::Ci::Pipelines,
          ::API::Ci::PipelineSchedules, ::API::Ci::Runners, ::API::Ci::Runner,
          ::API::Commits, ::API::CommitStatuses, ::API::ContainerRegistryEvent,
          ::API::DeployKeys, ::API::DeployTokens, ::API::Deployments, ::API::Environments,
          ::API::ErrorTracking, ::API::Events, ::API::FeatureFlags, ::API::FeatureFlagScopes,
          ::API::FeatureFlagsUserLists, ::API::Features, ::API::Files, ::API::FreezePeriods,
          ::API::GroupBoards, ::API::GroupClusters, ::API::GroupExport, ::API::GroupImport,
          ::API::GroupLabels, ::API::GroupMilestones, ::API::Groups,
          ::API::GroupContainerRepositories, ::API::GroupVariables,
          ::API::ImportBitbucketServer, ::API::ImportGithub, ::API::IssueLinks,
          ::API::Issues, ::API::JobArtifacts, ::API::Jobs, ::API::Keys, ::API::Labels,
          ::API::Lint, ::API::Markdown, ::API::Members, ::API::MergeRequestDiffs,
          ::API::MergeRequests, ::API::MergeRequestApprovals, ::API::Metrics::Dashboard::Annotations,
          ::API::Metrics::UserStarredDashboards, ::API::Namespaces, ::API::Notes
        ]
        next unless completed_classes.include?(klass)

        "#{klass}##{path}"
      end.compact.uniq
    end

    it "has feature categories" do
      expect(routes_without_category).to be_empty, "#{routes_without_category} did not have a category"
    end

    it "recognizes the feature categories" do
      routes_unknown_category = api_endpoints.map do |(klass, path)|
        used_category = klass.try(:feature_category_for_action, path)
        next unless used_category
        next if used_category == :not_owned

        [path, used_category] unless feature_categories.include?(used_category)
      end.compact

      expect(routes_unknown_category).to be_empty, "#{routes_unknown_category.first(10)} had an unknown category"
    end

    # This is required for API::Base.path_for_app to work, as it picks
    # the first path
    it "has no routes with multiple paths" do
      routes_with_multiple_paths = API::API.routes.select { |route| route.app.options[:path].length != 1 }
      failure_routes = routes_with_multiple_paths.map { |route| "#{route.app.options[:for]}:[#{route.app.options[:path].join(', ')}]" }

      expect(routes_with_multiple_paths).to be_empty, "#{failure_routes} have multiple paths"
    end

    it "doesn't define or exclude categories on removed actions", :aggregate_failures do
      api_endpoints.group_by(&:first).each do |klass, paths|
        existing_paths = paths.map(&:last)
        used_paths = paths_defined_in_feature_category_config(klass)
        non_existing_used_paths = used_paths - existing_paths

        expect(non_existing_used_paths).to be_empty,
                                           "#{klass} used #{non_existing_used_paths} to define feature category, but the route does not exist"
      end
    end
  end

  def paths_defined_in_feature_category_config(klass)
    (klass.try(:class_attributes) || {}).fetch(:feature_category_config, {})
      .values
      .flatten
      .map(&:to_s)
  end
end
