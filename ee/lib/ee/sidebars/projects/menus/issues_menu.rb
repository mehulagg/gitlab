# frozen_string_literal: true

module EE
  module Sidebars
    module Projects
      module Menus
        module IssuesMenu
          extend ::Gitlab::Utils::Override

          override :configure_menu_items
          def configure_menu_items
            return false unless super

            add_item(iterations_menu_item)

            true
          end

          private

          def iterations_menu_item
            if !context.project.licensed_feature_available?(:iterations) ||
              !can?(context.current_user, :read_iteration, context.project)
              return ::Sidebars::NilMenuItem.new(item_id: :iterations)
            end

            ::Sidebars::MenuItem.new(
              title: _('Iterations'),
              link: project_iterations_path(context.project),
              active_routes: { controller: :iterations },
              item_id: :iterations
            )
          end
        end
      end
    end
  end
end
