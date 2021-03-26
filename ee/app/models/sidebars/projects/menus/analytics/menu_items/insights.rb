# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Analytics
        module MenuItems
          class Insights < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_insights_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                class: 'shortcuts-project-insights',
                data: { qa_selector: 'project_insights_link' }
              }
            end

            override :active_routes
            def active_routes
              { path: 'insights#show' }
            end

            override :item_name
            def item_name
              _('Insights')
            end

            override :render?
            def render?
              context.project.insights_available?
            end
          end
        end
      end
    end
  end
end
