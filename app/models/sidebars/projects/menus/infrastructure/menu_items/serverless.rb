# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Infrastructure
        module MenuItems
          class Serverless < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_serverless_functions_path(context.project)
            end

            override :active_routes
            def active_routes
              { controller: :functions }
            end

            override :item_name
            def item_name
              _('Serverless')
            end

            override :render?
            def render?
              can?(context.current_user, :read_cluster, context.project)
            end
          end
        end
      end
    end
  end
end
