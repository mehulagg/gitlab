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
            return unless context.project.licensed_feature_available?(:iterations)
            return unless can?(context.current_user, :read_iteration, context.project)

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
