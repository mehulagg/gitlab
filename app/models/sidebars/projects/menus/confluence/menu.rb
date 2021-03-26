# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Confluence
        class Menu < ::Sidebars::Menu
          override :menu_link
          def menu_link
            project_wikis_confluence_path(context.project)
          end

          override :extra_menu_container_html_options
          def extra_menu_container_html_options
            {
              class: 'shortcuts-confluence',
              target: '_blank',
              rel: 'noopener noreferrer'
            }
          end

          override :menu_name
          def menu_name
            _('Confluence')
          end

          override :menu_name_html_options
          def menu_name_html_options
            {
              data: { qa_selector: 'analytics_link' }
            }
          end

          override :image_path
          def image_path
            'confluence.svg'
          end

          override :image_html_options
          def image_html_options
            {
              alt: menu_name
            }
          end

          override :render?
          def render?
            context.project.has_confluence?
          end
        end
      end
    end
  end
end
