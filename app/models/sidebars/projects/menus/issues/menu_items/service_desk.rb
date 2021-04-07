# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        module MenuItems
          class ServiceDesk < ::Sidebars::MenuItem
            override :link
            def link
              service_desk_project_issues_path(context.project)
            end

            override :active_routes
            def active_routes
              { path: 'issues#service_desk' }
            end

            override :title
            def title
              _('Service Desk')
            end
          end
        end
      end
    end
  end
end
