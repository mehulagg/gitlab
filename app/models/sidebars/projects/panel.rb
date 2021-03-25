# frozen_string_literal: true

module Sidebars
  module Projects
    class Panel < ::Sidebars::Panel
      override :configure_menus
      def configure_menus
        set_context_menu(Sidebars::Projects::Menus::Context::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::ProjectOverview::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::LearnGitlab::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::Repository::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::Issues::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::ExternalIssueTracker::Menu.new(context))
      end

      override :aria_label
      def aria_label
        _('Project navigation')
      end
    end
  end
end
