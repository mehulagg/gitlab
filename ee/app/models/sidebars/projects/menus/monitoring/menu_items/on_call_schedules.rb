# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Monitoring
        module MenuItems
          class OnCallSchedules < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_incident_management_oncall_schedules_path(context.project)
            end

            override :active_routes
            def active_routes
              { controller: :oncall_schedules }
            end

            override :item_name
            def item_name
              _('On-call Schedules')
            end

            override :render?
            def render?
              can?(context.current_user, :read_incident_management_oncall_schedule, context.project)
            end
          end
        end
      end
    end
  end
end
