# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module ProjectOverview
        module MenuItems
          class Activity < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              activity_project_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: _('Activity'),
                class: 'shortcuts-project-activity',
                data: { qa_selector: 'activity_link' }
              }
            end

            override :nav_link_params
            def nav_link_params
              { path: 'projects#activity' }
            end

            override :item_name
            def item_name
              _('Activity')
            end
          end
        end
      end
    end
  end
end
