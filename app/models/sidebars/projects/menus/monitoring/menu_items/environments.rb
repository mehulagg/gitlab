# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Monitoring
        module MenuItems
          class Environments < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_environments_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                class: 'shortcuts-environments qa-operations-environments-link'
              }
            end

            override :active_routes
            def active_routes
              { controller: :environments }
            end

            override :item_name
            def item_name
              _('Environments')
            end

            override :render?
            def render?
              can?(context.current_user, :read_environment, context.project)
            end
          end
        end
      end
    end
  end
end
