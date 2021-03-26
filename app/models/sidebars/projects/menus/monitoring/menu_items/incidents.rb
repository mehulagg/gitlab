# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Monitoring
        module MenuItems
          class Incidents < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_incidents_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                data: { qa_selector: 'operations_incidents_link' }
              }
            end

            override :active_routes
            def active_routes
              { controller: :incidents }
            end

            override :item_name
            def item_name
              _('Incidents')
            end

            override :render?
            def render?
              can?(context.current_user, :read_issue, context.project)
            end
          end
        end
      end
    end
  end
end
