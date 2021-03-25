# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module ExternalIssueTracker
        module MenuItems
          class JiraIssueList < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              project_integrations_jira_issues_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: s_('JiraService|Issue List')
              }
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
