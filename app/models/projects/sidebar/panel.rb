# frozen_string_literal: true

module Projects
  module Sidebar
    class Panel < ::Sidebar::Panel
      def initialize(current_user, project, current_ref)
        super(current_user, project)

        set_context_menu(Projects::Sidebar::Menus::ContextMenu.new(current_user, project))
        add_menu(Projects::Sidebar::Menus::ProjectOverviewMenu.new(current_user, project))
        add_menu(Projects::Sidebar::Menus::LearnGitlabMenu.new(current_user, project))
        add_menu(Projects::Sidebar::Menus::RepositoryMenu.new(current_user, project, current_ref))
      end

      def aria_label
        _('Project navigation')
      end
    end
  end
end
