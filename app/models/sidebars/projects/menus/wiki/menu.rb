# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Wiki
        class Menu < ::Sidebars::Menu
          override :menu_link
          def menu_link
            wiki_path(context.project.wiki)
          end

          override :extra_menu_container_html_options
          def extra_menu_container_html_options
            {
              class: 'shortcuts-wiki',
              data: { qa_selector: 'wiki_link' }
            }
          end

          override :menu_name
          def menu_name
            _('Wiki')
          end

          override :active_routes
          def active_routes
            { controller: :wikis }
          end

          override :menu_name_html_options
          def menu_name_html_options
            {
              data: { qa_selector: 'analytics_link' }
            }
          end

          override :sprite_icon
          def sprite_icon
            'book'
          end

          override :render?
          def render?
            can?(context.current_user, :read_wiki, context.project) &&
              !context.project.has_confluence?
          end
        end
      end
    end
  end
end
