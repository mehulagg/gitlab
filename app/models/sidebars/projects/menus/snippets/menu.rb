# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Snippets
        class Menu < ::Sidebars::Menu
          override :menu_link
          def menu_link
            project_snippets_path(context.project)
          end

          override :extra_menu_container_html_options
          def extra_menu_container_html_options
            {
              class: 'shortcuts-snippets',
              data: { qa_selector: 'snippets_link' }
            }
          end

          override :menu_name
          def menu_name
            _('Snippets')
          end

          override :active_routes
          def active_routes
            { controller: :snippets }
          end

          override :menu_name_html_options
          def menu_name_html_options
            {
              data: { qa_selector: 'analytics_link' }
            }
          end

          override :sprite_icon
          def sprite_icon
            'snippet'
          end

          override :render?
          def render?
            can?(context.current_user, :read_snippet, context.project)
          end
        end
      end
    end
  end
end
