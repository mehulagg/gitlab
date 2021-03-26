# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Infrastructure
        class Menu < ::Sidebars::Menu
          override :configure_menu_items
          def configure_menu_items
            add_item(MenuItems::Serverless.new(context))
            add_item(MenuItems::Terraform.new(context))
            add_item(MenuItems::Kubernetes.new(context))
          end

          override :menu_link
          def menu_link
            @renderable_items.first.item_link
          end

          override :menu_name
          def menu_name
            _('Infrastructure')
          end

          override :sprite_icon
          def sprite_icon
            'cloud-gear'
          end

          override :render?
          def render?
            context.project.feature_available?(:operations, context.current_user) && has_renderable_items?
          end
        end
      end
    end
  end
end
