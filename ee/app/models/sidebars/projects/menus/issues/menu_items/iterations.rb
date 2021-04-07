# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        module MenuItems
          class Iterations < ::Sidebars::MenuItem
            override :link
            def link
              project_iterations_path(context.project)
            end

            override :active_routes
            def active_routes
              { controller: :iterations }
            end

            override :title
            def title
              _('Iterations')
            end

            override :render?
            def render?
              context.project.licensed_feature_available?(:iterations) &&
                can?(context.current_user, :read_iteration, context.project)
            end
          end
        end
      end
    end
  end
end
