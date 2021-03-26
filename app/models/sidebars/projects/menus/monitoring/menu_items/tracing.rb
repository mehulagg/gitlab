# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Monitoring
        module MenuItems
          class Tracing < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_tracing_path(context.project)
            end

            override :active_routes
            def active_routes
              { path: 'tracings#show' }
            end

            override :item_name
            def item_name
              _('Tracing')
            end

            override :render?
            def render?
              can?(context.current_user, :read_environment, context.project) &&
                can?(context.current_user, :admin_project, context.project)
            end
          end
        end
      end
    end
  end
end
