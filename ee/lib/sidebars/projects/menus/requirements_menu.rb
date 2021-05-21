# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      class RequirementsMenu < ::Sidebars::Menu
        override :link
        def link
          project_requirements_management_requirements_path(context.project)
        end

        override :configure_menu_items
        def configure_menu_items
          add_item(list_menu_item)
        end

        override :render?
        def render?
          can?(context.current_user, :read_requirement, context.project)
        end

        override :title
        def title
          _('Requirements')
        end

        override :sprite_icon
        def sprite_icon
          'requirements'
        end

        override :active_routes
        def active_routes
          { path: 'requirements#index' }
        end

        private

        def list_menu_item
          if Feature.enabled?(:sidebar_refactor, context.current_user, default_enabled: :yaml)
            return ::Sidebars::NilMenuItem.new(item_id: :requirements_list)
          end

          ::Sidebars::MenuItem.new(
            title: _('List'),
            link: project_requirements_management_requirements_path(context.project),
            active_routes: { path: 'requirements#index' },
            item_id: :requirements_list
          )
        end
      end
    end
  end
end
