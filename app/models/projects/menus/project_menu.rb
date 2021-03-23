# frozen_string_literal: true

module Projects
  module Menus
    class ProjectMenu < SidebarMenu
      def link
        project_path(container)
      end

      def item_name
        _('Project overview')
      end

      def sprite_icon
        'home'
      end
    end
  end
end
