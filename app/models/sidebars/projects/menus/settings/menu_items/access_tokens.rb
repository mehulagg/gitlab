# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Settings
        module MenuItems
          class AccessTokens < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_settings_access_tokens_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                data: { qa_selector: 'access_tokens_settings_link' }
              }
            end

            override :active_routes
            def active_routes
              { controller: [:access_tokens] }
            end

            override :item_name
            def item_name
              _('Access Tokens')
            end
          end
        end
      end
    end
  end
end
