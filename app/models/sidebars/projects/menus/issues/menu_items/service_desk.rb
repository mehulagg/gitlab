# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        module MenuItems
          class ServiceDesk < ::Sidebars::MenuItem
            override :item_link
            def item_link
              service_desk_project_issues_path(context.project)
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
end
