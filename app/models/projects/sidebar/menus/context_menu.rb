# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      class ContextMenu < ::Sidebar::Menu
        override :link_to_href
        def link_to_href
          project_path(container)
        end

        override :link_to_attributes
        def link_to_attributes
          {
            title: menu_name
          }
        end

        override :menu_name
        def menu_name
          container.name
        end
      end
    end
  end
end
