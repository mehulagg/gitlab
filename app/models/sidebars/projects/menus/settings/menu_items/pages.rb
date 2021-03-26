# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Settings
        module MenuItems
          class Pages < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_pages_path(context.project)
            end

            override :active_routes
            def active_routes
              { controller: :pages }
            end

            override :item_name
            def item_name
              _('Pages')
            end

            override :render?
            def render?
              context.project.pages_available?
            end
          end
        end
      end
    end
  end
end
