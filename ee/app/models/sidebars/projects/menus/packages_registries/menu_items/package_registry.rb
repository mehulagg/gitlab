# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module PackagesRegistries
        module MenuItems
          class PackageRegistry < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_packages_path(context.project)
            end

            override :active_routes
            def active_routes
              { controller: :packages }
            end

            override :item_name
            def item_name
              _('Package Registry')
            end

            override :render?
            def render?
              ::Gitlab.config.packages.enabled &&
                can?(context.current_user, :read_package, context.project)
            end
          end
        end
      end
    end
  end
end
