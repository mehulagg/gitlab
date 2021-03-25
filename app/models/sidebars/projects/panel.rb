# frozen_string_literal: true

module Sidebars
  module Projects
    class Panel < ::Sidebars::Panel
      def initialize(context)
        super

        set_context_menu(Sidebars::Projects::Menus::Context::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::ProjectOverview::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::LearnGitlab::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::Repository::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::Issues::Menu.new(context))
      end

      def aria_label
        _('Project navigation')
      end
    end
  end
end
