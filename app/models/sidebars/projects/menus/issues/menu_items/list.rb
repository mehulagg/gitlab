# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        module MenuItems
          class List < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_issues_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
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
