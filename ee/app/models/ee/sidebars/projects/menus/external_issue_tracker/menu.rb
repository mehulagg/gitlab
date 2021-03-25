# frozen_string_literal: true

module EE
  module Sidebars
    module Projects
      module Menus
        module ExternalIssueTracker
          module Menu
            extend ::Gitlab::Utils::Override

            override :configure_menu_items
            def configure_menu_items
              return super unless jira_issues_integration?

              add_item(::Sidebars::Projects::Menus::ExternalIssueTracker::MenuItems::JiraIssueList.new(context))
              add_item(::Sidebars::Projects::Menus::ExternalIssueTracker::MenuItems::OpenJira.new(context))
            end

            override :link_to_href
            def link_to_href
              project_integrations_jira_issues_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: menu_name
              }
            end

            override :menu_name
            def menu_name
              s_('JiraService|Jira Issues')
            end

            override :menu_name_html_options
            def menu_name_html_options
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

            private

            def jira_issues_integration?
              external_issue_tracker.is_a?(JiraService) &&
                context.project.jira_issues_integration_available? &&
                context.project.jira_service.issues_enabled
            end
          end
        end
      end
    end
  end
end
