# frozen_string_literal: true

module EE
  module Sidebars
    module Projects
      module Menus
        module OperationsMenu
          extend ::Gitlab::Utils::Override

          override :configure_menu_items
          def configure_menu_items
            return false unless super

            insert_item_after(:incidents, on_call_schedules_menu_item)

            true
          end

          private

          def on_call_schedules_menu_item
            return unless can?(context.current_user, :read_incident_management_oncall_schedule, context.project)

            ::Sidebars::MenuItem.new(
              title: _('On-call Schedules'),
              link: project_incident_management_oncall_schedules_path(context.project),
              active_routes: { controller: :oncall_schedules },
              item_id: :on_call_schedules
            )
          end
        end
      end
    end
  end
end
