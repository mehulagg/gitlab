# frozen_string_literal: true

module Projects
  module Sidebar
    module Menus
      module Items
        class IterationsMenuItem < ::Sidebar::MenuItem
          override :link_to_href
          def link_to_href
            project_iterations_path(context.project)
          end

          override :link_to_attributes
          def link_to_attributes
            {
              title: _('Iterations')
            }
          end

          override :nav_link_params
          def nav_link_params
            { controller: :iterations }
          end

          override :item_name
          def item_name
            _('Iterations')
          end

          override :render?
          def render?
            context.project.feature_available?(:iterations) &&
              can?(context.current_user, :read_iteration, context.project)
          end
        end
      end
    end
  end
end
