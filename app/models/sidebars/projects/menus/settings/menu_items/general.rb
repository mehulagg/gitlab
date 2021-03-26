# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Settings
        module MenuItems
          class General < ::Sidebars::MenuItem
            override :item_link
            def item_link
              edit_project_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                class: 'qa-general-settings-link'
              }
            end

            override :active_routes
            def active_routes
              { path: 'projects#edit' }
            end

            override :item_name
            def item_name
              _('General')
            end
          end
        end
      end
    end
  end
end
