# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Monitoring
        module MenuItems
          class AlertManagement < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_alert_management_index_path(context.project)
            end

            override :active_routes
            def active_routes
              { controller: :alert_management }
            end

            override :item_name
            def item_name
              _('Alerts')
            end

            override :render?
            def render?
              can?(context.current_user, :read_alert_management_alert, context.project)
            end
          end
        end
      end
    end
  end
end
