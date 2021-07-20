# frozen_string_literal: true

module EE
  module Analytics
    module NavbarHelper
      extend ::Gitlab::Utils::Override

      override :group_analytics_navbar_links
      def group_analytics_navbar_links(group, current_user)
        super + [
          group_ci_cd_analytics_navbar_link(group, current_user),
          group_devops_adoption_navbar_link(group, current_user),
          group_repository_analytics_navbar_link(group, current_user),
          contribution_analytics_navbar_link(group, current_user),
          group_insights_navbar_link(group, current_user),
          issues_analytics_navbar_link(group, current_user),
          productivity_analytics_navbar_link(group, current_user),
          group_cycle_analytics_navbar_link(group, current_user),
          group_merge_request_analytics_navbar_link(group, current_user)
        ].compact
      end

      private

      # Currently an empty page, so don't show it on the navbar for now
      def group_merge_request_analytics_navbar_link(group, current_user)
        return
        return unless group_sidebar_link?(:merge_request_analytics) # rubocop: disable Lint/UnreachableCode

        navbar_sub_item(
          title: _('Merge request'),
          path: 'groups/analytics/merge_request_analytics#show',
          link: group_analytics_merge_request_analytics_path(group)
        )
      end

      def group_cycle_analytics_navbar_link(group, current_user)
        return unless group_sidebar_link?(:cycle_analytics)

        navbar_sub_item(
          title: _('Value stream'),
          path: 'groups/analytics/cycle_analytics#show',
          link: group_analytics_cycle_analytics_path(group)
        )
      end

      def group_devops_adoption_navbar_link(group, current_user)
        return unless group_sidebar_link?(:group_devops_adoption)

        navbar_sub_item(
          title: _('DevOps adoption'),
          path: 'groups/analytics/devops_adoption#show',
          link: group_analytics_devops_adoption_path(group)
        )
      end

      def productivity_analytics_navbar_link(group, current_user)
        return unless group_sidebar_link?(:productivity_analytics)

        navbar_sub_item(
          title: _('Productivity'),
          path: 'groups/analytics/productivity_analytics#show',
          link: group_analytics_productivity_analytics_path(group)
        )
      end

      def contribution_analytics_navbar_link(group, current_user)
        return unless group_sidebar_link?(:contribution_analytics)

        navbar_sub_item(
          title: _('Contribution'),
          path: 'groups/contribution_analytics#show',
          link: group_contribution_analytics_path(group),
          link_to_options: { data: { placement: 'right', qa_selector: 'contribution_analytics_link' } }
        )
      end

      def group_insights_navbar_link(group, current_user)
        return unless group_sidebar_link?(:group_insights)

        navbar_sub_item(
          title: _('Insights'),
          path: 'groups/insights#show',
          link:  group_insights_path(group),
          link_to_options: { class: 'shortcuts-group-insights', data: { qa_selector: 'group_insights_link' } }
        )
      end

      def issues_analytics_navbar_link(group, current_user)
        return unless group_sidebar_link?(:analytics)

        navbar_sub_item(
          title: _('Issue'),
          path: 'issues_analytics#show',
          link: group_issues_analytics_path(group)
        )
      end

      def group_ci_cd_analytics_navbar_link(group, current_user)
        return unless group.licensed_feature_available?(:group_ci_cd_analytics)
        return unless group_sidebar_link?(:group_ci_cd_analytics)

        navbar_sub_item(
          title: _('CI/CD'),
          path: 'groups/analytics/ci_cd_analytics#show',
          link: group_analytics_ci_cd_analytics_path(group)
        )
      end

      def group_repository_analytics_navbar_link(group, current_user)
        return unless group.licensed_feature_available?(:group_coverage_reports)
        return unless group_sidebar_link?(:repository_analytics)

        navbar_sub_item(
          title: _('Repositories'),
          path: 'groups/analytics/repository_analytics#show',
          link: group_analytics_repository_analytics_path(group)
        )
      end
    end
  end
end
