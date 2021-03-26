# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Settings
        module MenuItems
          class WebHooks < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_hooks_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                data: { qa_selector: 'webhooks_settings_link' }
              }
            end

            override :active_routes
            def active_routes
              { controller: [:hooks, :hook_logs] }
            end

            override :item_name
            def item_name
              _('Webhooks')
            end
          end
        end
      end
    end
  end
end
