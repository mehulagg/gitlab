# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Analytics
        class Menu < ::Sidebars::Menu
          override :configure_menu_items
          def configure_menu_items
            add_item(MenuItems::ValueStream.new(context))
            add_item(MenuItems::Repository.new(context))
            add_item(MenuItems::CiCd.new(context))
          end

          override :menu_link
          def menu_link
            renderable_items.first.item_link
          end

          override :extra_menu_container_html_options
          def extra_menu_container_html_options
            {
              class: 'shortcuts-analytics',
              data: { qa_selector: 'analytics_anchor' }
            }
          end

          override :menu_name
          def menu_name
            _('Analytics')
          end

          override :menu_name_html_options
          def menu_name_html_options
            {
              data: { qa_selector: 'analytics_link' }
            }
          end

          override :sprite_icon
          def sprite_icon
            'doc-text'
          end

          override :render?
          def render?
            has_renderable_items?
          end
        end
      end
    end
  end
end

Sidebars::Projects::Menus::Analytics::Menu.prepend_if_ee('EE::Sidebars::Projects::Menus::Analytics::Menu')
