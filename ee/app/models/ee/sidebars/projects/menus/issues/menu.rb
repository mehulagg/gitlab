# frozen_string_literal: true

module EE
  module Sidebars
    module Projects
      module Menus
        module Issues
          module Menu
            extend ::Gitlab::Utils::Override

            override :configure_menu_items
            def configure_menu_items
              super

              add_item(::Sidebars::Projects::Menus::Issues::MenuItems::Iterations.new(context))
            end
          end
        end
      end
    end
  end
end
