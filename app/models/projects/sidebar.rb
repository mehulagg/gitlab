# frozen_string_literal: true

module Projects
  class Sidebar < ::Sidebar
    def initialize(project)
      super(project)

      set_context_menu(Projects::Menus::ContextMenu.new(project))
      add_menu(Projects::Menus::ProjectMenu.new(project))
    end
  end
end
