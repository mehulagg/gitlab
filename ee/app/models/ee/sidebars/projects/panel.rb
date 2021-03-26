# frozen_string_literal: true

module EE
  module Sidebars
    module Projects
      module Panel
        extend ::Gitlab::Utils::Override

        override :configure_menus
        def configure_menus
          super

          insert_menu_after(::Sidebars::Projects::Menus::MergeRequests::Menu, ::Sidebars::Projects::Menus::Requirements::Menu.new(context))
          insert_menu_after(::Sidebars::Projects::Menus::Infrastructure::Menu, ::Sidebars::Projects::Menus::PackagesRegistries::Menu.new(context))
        end
      end
    end
  end
end
