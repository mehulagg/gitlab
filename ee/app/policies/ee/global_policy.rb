# frozen_string_literal: true

module EE
  module GlobalPolicy
    extend ActiveSupport::Concern

    prepended do
      condition(:operations_dashboard_available) do
        License.feature_available?(:operations_dashboard)
      end

      condition(:pages_size_limit_available) do
        License.feature_available?(:pages_size_limit)
      end

      condition(:adjourned_project_deletion_available) do
        License.feature_available?(:adjourned_deletion_for_projects_and_groups)
      end

      condition(:export_user_permissions_available) do
        ::License.feature_available?(:export_user_permissions) && ::Feature.enabled?(:export_user_permissions_feature_flag)
      end

      rule { ~anonymous & operations_dashboard_available }.enable :read_operations_dashboard

      rule { admin }.policy do
        enable :read_licenses
        enable :destroy_licenses
        enable :read_all_geo
        enable :manage_devops_adoption_segments
        enable :manage_subscription
      end

      rule { admin & pages_size_limit_available }.enable :update_max_pages_size

      rule { ~anonymous }.policy do
        enable :view_productivity_analytics
      end

      rule { ~(admin | allow_to_manage_default_branch_protection) }.policy do
        prevent :create_group_with_default_branch_protection
      end

      rule { admin & adjourned_project_deletion_available }.policy do
        enable :list_removable_projects
      end

      rule { export_user_permissions_available & admin }.enable :export_user_permissions
    end
  end
end
