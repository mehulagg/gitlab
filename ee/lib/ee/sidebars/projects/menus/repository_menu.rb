# frozen_string_literal: true

module EE
  module Sidebars
    module Projects
      module Menus
        module RepositoryMenu
          extend ::Gitlab::Utils::Override

          override :configure_menu_items
          def configure_menu_items
            super

            add_item(file_locks_menu_item)
          end

          private

          def file_locks_menu_item
            return unless context.project.licensed_feature_available?(:file_locks)

            ::Sidebars::MenuItem.new(
              title: _('Locked Files'),
              link: project_path_locks_path(context.project),
              active_routes: { controller: :path_locks },
              item_id: :file_locks
            )
          end
        end
      end
    end
  end
end
