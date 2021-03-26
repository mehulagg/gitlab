# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module ExternalWiki
        class Menu < ::Sidebars::Menu
          override :menu_link
          def menu_link
            context.project.external_wiki.external_wiki_url
          end

          override :extra_menu_container_html_options
          def extra_menu_container_html_options
            {
              class: 'shortcuts-external_wiki'
            }
          end

          override :menu_name
          def menu_name
            _('External Wiki')
          end

          override :sprite_icon
          def sprite_icon
            'external-link'
          end

          override :render?
          def render?
            context.project.external_wiki
          end
        end
      end
    end
  end
end
