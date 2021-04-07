# frozen_string_literal: true

module Sidebars
  module Projects
    class Panel < ::Sidebars::Panel
      override :configure_menus
      def configure_menus
        set_scope_menu(Sidebars::Projects::Menus::Scope::Menu.new(context))
      end

      override :aria_label
      def aria_label
        _('Project navigation')
      end
    end
  end
end
