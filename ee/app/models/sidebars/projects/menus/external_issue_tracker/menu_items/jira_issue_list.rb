# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module ExternalIssueTracker
        module MenuItems
          class JiraIssueList < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_integrations_jira_issues_path(context.project)
            end

            override :nav_link_params
            def nav_link_params
              { page: 'projects/integrations/jira/issues#index' }
            end

            override :item_name
            def item_name
              s_('JiraService|Issue List')
            end
          end
        end
      end
    end
  end
end
