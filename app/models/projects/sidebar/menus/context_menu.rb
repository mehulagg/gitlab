# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      class ContextMenu < ::Sidebar::Menu
        override :link_to_href
        def link_to_href
          project_path(context.project)
        end

        override :link_to_attributes
        def link_to_attributes
          {
            title: menu_name
          }
        end

        override :menu_name
        def menu_name
          context.project.name
        end
      end
    end
  end
end
