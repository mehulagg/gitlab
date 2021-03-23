# frozen_string_literal: true

module Projects
  module Menus
    class ContextMenu < SidebarMenu
      extend ::Gitlab::Utils::Override

      # alias_attribute :container, :project

      def link
        project_path(container)
      end

      def item_name
        container.path
      end

      override :to_partial_path
      def to_partial_path
        'projects/menus/context_menu'
      end
    end
  end
end
