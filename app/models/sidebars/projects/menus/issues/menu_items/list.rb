# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        module MenuItems
          class List < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              project_issues_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: _('Issues')
              }
            end

            override :nav_link_params
            def nav_link_params
              { path: 'issues#index' }
            end

            override :item_name
            def item_name
              _('List')
            end
          end
        end
      end
    end
  end
end
