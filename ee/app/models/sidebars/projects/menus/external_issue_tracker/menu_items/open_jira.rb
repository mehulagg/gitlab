# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module ExternalIssueTracker
        module MenuItems
          class OpenJira < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              context.project.external_issue_tracker.issue_tracker_path
            end

            override :link_to_attributes
            def link_to_attributes
              {
                target: '_blank',
                rel: 'noopener noreferrer'
              }
            end

            override :item_name
            def item_name
              s_('JiraService|Open Jira')
            end

            override :sprite_icon
            def sprite_icon
              'external-link'
            end

            override :sprite_icon_html_options
            def sprite_icon_html_options
              {
                css_class: 'gl-vertical-align-text-bottom'
              }
            end
          end
        end
      end
    end
  end
end
