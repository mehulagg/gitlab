# frozen_string_literal: true

module EE
  module Sidebars
    module Projects
      module Menus
        module CiCd
          module Menu
            extend ::Gitlab::Utils::Override

            override :configure_menu_items
            def configure_menu_items
              super

              add_item(::Sidebars::Projects::Menus::CiCd::MenuItems::TestCases.new(context))
            end
          end
        end
      end
    end
  end
end
