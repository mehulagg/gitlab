# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module ProjectOverview
        module MenuItems
          class Details < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              project_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: _('Project details'),
                class: 'shortcuts-project'
              }
            end

            override :nav_link_params
            def nav_link_params
              { path: 'projects#show' }
            end

            override :item_name
            def item_name
              _('Details')
            end
          end
        end
      end
    end
  end
end
