# frozen_string_literal: true

module Packages
  class GroupPackagesFinder
    include ::Packages::FinderHelper

    def initialize(current_user, group, params = { exclude_subgroups: false, order_by: 'created_at', sort: 'asc' })
      @current_user = current_user
      @group = group
      @params = params
    end

    def execute
      return ::Packages::Package.none unless group

      packages_for_group_projects
    end

    private

    attr_reader :current_user, :group, :params

    def packages_for_group_projects
      packages = ::Packages::Package
        .including_build_info
        .including_project_route
        .including_tags
        .for_projects(group_projects_visible_to_current_user.select(:id))
        .processed
        .sort_by_attribute("#{params[:order_by]}_#{params[:sort]}")

      packages = filter_with_version(packages)
      packages = filter_by_package_type(packages)
      packages = filter_by_package_name(packages)
      packages = filter_by_status(packages)
      packages
    end

    def group_projects_visible_to_current_user
      # according to project_policy.rb
      # access to packages is ruled by:
      # - project is public or the current user has access to it with at least the reporter level
      # - the repository feature is available to the current_user
      group_projects
        .public_or_visible_to_user(current_user, Gitlab::Access::REPORTER)
        .with_feature_available_for_user(:repository, current_user)
    end

    def group_projects
      return group.projects if exclude_subgroups?

      group.all_projects
    end

    def exclude_subgroups?
      params[:exclude_subgroups]
    end
  end
end
