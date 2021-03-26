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
        add_menu(Sidebars::Projects::Menus::Labels::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::MergeRequests::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::CiCd::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::SecurityCompliance::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::Monitoring::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::Infrastructure::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::Analytics::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::Confluence::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::Wiki::Menu.new(context))
        add_menu(Sidebars::Projects::Menus::ExternalWiki::Menu.new(context))
      end

      override :aria_label
      def aria_label
        _('Project navigation')
      end
    end
  end
end

Sidebars::Projects::Panel.prepend_if_ee('EE::Sidebars::Projects::Panel')
