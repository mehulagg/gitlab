# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Analytics
        module MenuItems
          class ValueStream < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_cycle_analytics_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                class: 'shortcuts-project-cycle-analytics'
              }
            end

            override :active_routes
            def active_routes
              { path: 'cycle_analytics#show' }
            end

            override :item_name
            def item_name
              _('Value Stream')
            end

            override :render?
            def render?
              can?(context.current_user, :read_cycle_analytics, context.project)
            end
          end
        end
      end
    end
  end
end
