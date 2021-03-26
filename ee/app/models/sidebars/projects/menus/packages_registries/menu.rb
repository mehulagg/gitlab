# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module PackagesRegistries
        class Menu < ::Sidebars::Menu
          override :configure_menu_items
          def configure_menu_items
            add_item(MenuItems::PackageRegistry.new(context))
            add_item(MenuItems::ContainerRegistry.new(context))
          end

          override :menu_link
          def menu_link
            renderable_items.first.item_link
          end

          override :extra_menu_container_html_options
          def extra_menu_container_html_options
            {
              data: { qa_selector: 'packages_link' }
            }
          end

          override :render?
          def render?
            has_renderable_items?
          end

          override :menu_name
          def menu_name
            _('Packages & Registries')
          end

          override :sprite_icon
          def sprite_icon
            'package'
          end
        end
      end
    end
  end
end
