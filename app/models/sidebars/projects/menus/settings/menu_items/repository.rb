# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Settings
        module MenuItems
          class Repository < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_settings_repository_path(context.project)
            end

            override :active_routes
            def active_routes
              { controller: :repository }
            end

            override :item_name
            def item_name
              _('Repository')
            end
          end
        end
      end
    end
  end
end
