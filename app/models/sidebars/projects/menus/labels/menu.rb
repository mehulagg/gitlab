# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Labels
        class Menu < ::Sidebars::Menu
          override :menu_link
          def menu_link
            project_labels_path(context.project)
          end

          override :extra_menu_container_html_options
          def extra_menu_container_html_options
            {
              class: 'shortcuts-labels qa-labels-items'
            }
          end

          override :menu_name
          def menu_name
            _('Labels')
          end

          override :menu_name_html_options
          def menu_name_html_options
            {
              id: '#js-onboarding-labels-link'
            }
          end

          override :active_routes
          def active_routes
            { controller: :labels }
          end

          override :sprite_icon
          def sprite_icon
            'label'
          end

          override :render?
          def render?
            can?(context.current_user, :read_label, context.project) && !context.project.issues_enabled?
          end
        end
      end
    end
  end
end
