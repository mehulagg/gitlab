# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Labels
        class Menu < ::Sidebars::Menu
          override :link_to_href
          def link_to_href
            project_labels_path(context.project)
          end

          override :link_to_attributes
          def link_to_attributes
            {
              title: _('Labels'),
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

          override :nav_link_params
          def nav_link_params
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
