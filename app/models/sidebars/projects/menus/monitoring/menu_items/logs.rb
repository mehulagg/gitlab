# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Monitoring
        module MenuItems
          class Logs < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_logs_path(context.project)
            end

            override :active_routes
            def active_routes
              { path: 'logs#index' }
            end

            override :item_name
            def item_name
              _('Logs')
            end

            override :render?
            def render?
              can?(context.current_user, :read_environment, context.project) &&
                can?(context.current_user, :read_pod_logs, context.project)
            end
          end
        end
      end
    end
  end
end
