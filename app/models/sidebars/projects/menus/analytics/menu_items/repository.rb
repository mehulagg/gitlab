# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Analytics
        module MenuItems
          class Repository < ::Sidebars::MenuItem
            override :item_link
            def item_link
              charts_project_graph_path(context.project, context.current_ref)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                class: 'shortcuts-repository-charts'
              }
            end

            override :active_routes
            def active_routes
              { path: 'graphs#charts' }
            end

            override :item_name
            def item_name
              _('Repository')
            end

            override :render?
            def render?
              !context.project.empty_repo?
            end
          end
        end
      end
    end
  end
end
