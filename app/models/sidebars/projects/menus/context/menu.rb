# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Context
        class Menu < ::Sidebars::Menu
          override :menu_link
          def menu_link
            project_path(context.project)
          end

          override :menu_name
          def menu_name
            context.project.name
          end
        end
      end
    end
  end
end
