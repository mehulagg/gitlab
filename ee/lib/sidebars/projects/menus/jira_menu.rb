# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      class JiraMenu < ::Sidebars::Menu
        override :configure_menu_items
        def configure_menu_items
          return false unless external_issue_tracker

          add_item(issue_list_menu_item)
          add_item(open_jira_menu_item)

          true
        end

        override :link
        def link
          project_integrations_jira_issues_path(context.project)
        end

        override :title
        def title
          s_('JiraService|Jira Issues')
        end

        override :title_html_options
        def title_html_options
          {
            id: 'js-onboarding-settings-link'
          }
        end

        override :image_path
        def image_path
          'logos/jira-gray.svg'
        end

        # Hardcode sizes so image doesn't flash before CSS loads https://gitlab.com/gitlab-org/gitlab/-/issues/321022
        override :image_html_options
        def image_html_options
          {
            size: 16
          }
        end

        override :render?
        def render?
          external_issue_tracker.is_a?(Integrations::Jira) && context.jira_issues_integration
        end

        private

        def external_issue_tracker
          @external_issue_tracker ||= context.project.external_issue_tracker
        end

        def issue_list_menu_item
          ::Sidebars::MenuItem.new(
            title: s_('JiraService|Issue List'),
            link: project_integrations_jira_issues_path(context.project),
            active_routes: { controller: 'projects/integrations/jira/issues' },
            item_id: :issue_list
          )
        end

        def open_jira_menu_item
          ::Sidebars::MenuItem.new(
            title: s_('JiraService|Open Jira'),
            link: external_issue_tracker.issue_tracker_path,
            active_routes: {},
            item_id: :open_jira,
            sprite_icon: 'external-link',
            container_html_options: {
              target: '_blank',
              rel: 'noopener noreferrer'
            }
          )
        end
      end
    end
  end
end
