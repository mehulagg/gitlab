# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Requirements
        class Menu < ::Sidebars::Menu
          override :menu_link
          def menu_link
            project_requirements_management_requirements_path(context.project)
          end

          override :extra_menu_container_html_options
          def extra_menu_container_html_options
            {
              class: 'qa-project-requirements-link'
            }
          end

          override :render?
          def render?
            can?(context.current_user, :read_requirement, context.project)
          end

          override :menu_name
          def menu_name
            _('Requirements')
          end

          override :sprite_icon
          def sprite_icon
            'requirements'
          end

          override :nav_link_params
          def nav_link_params
            { path: 'requirements#index' }
          end
        end
      end
    end
  end
end
