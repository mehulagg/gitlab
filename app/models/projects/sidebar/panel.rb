# frozen_string_literal: true

module Projects
  module Sidebar
    class Panel < ::Sidebar::Panel
      def initialize(context)
        super

        set_context_menu(Projects::Sidebar::Menus::ContextMenu.new(context))
        add_menu(Projects::Sidebar::Menus::ProjectOverviewMenu.new(context))
        add_menu(Projects::Sidebar::Menus::LearnGitlabMenu.new(context))
        add_menu(Projects::Sidebar::Menus::RepositoryMenu.new(context))
      end

      def aria_label
        _('Project navigation')
      end
    end
  end
end
