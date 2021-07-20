# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      class RequirementsMenu < ::Sidebars::Menu
        override :link
        def link
          project_requirements_management_requirements_path(context.project)
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
      end
    end
  end
end
