# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module ExternalIssueTracker
        module MenuItems
          class OpenJira < ::Sidebars::MenuItem
            override :item_link
            def item_link
              context.project.external_issue_tracker.issue_tracker_path
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
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
