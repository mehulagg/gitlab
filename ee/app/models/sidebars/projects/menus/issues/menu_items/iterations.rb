# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Issues
        module MenuItems
          class Iterations < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_iterations_path(context.project)
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
end
