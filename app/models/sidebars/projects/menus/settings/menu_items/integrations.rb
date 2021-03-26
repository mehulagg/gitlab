# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Settings
        module MenuItems
          class Integrations < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_settings_integrations_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                data: { qa_selector: 'integrations_settings_link' }
              }
            end

            override :active_routes
            def active_routes
              { controller: [:integrations, :services] }
            end

            override :item_name
            def item_name
              _('Integrations')
            end
          end
        end
      end
    end
  end
end
