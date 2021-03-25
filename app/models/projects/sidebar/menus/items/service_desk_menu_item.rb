# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      module Items
        class ServiceDeskMenuItem < ::Sidebar::MenuItem
          override :link_to_href
          def link_to_href
            service_desk_project_issues_path(context.project)
          end

          override :link_to_attributes
          def link_to_attributes
            {
              title: _('Service Desk')
            }
          end

          override :nav_link_params
          def nav_link_params
            { path: 'issues#service_desk' }
          end

          override :item_name
          def item_name
            _('Service Desk')
          end
        end
      end
    end
  end
end
