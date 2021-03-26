# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module Settings
        module MenuItems
          class Operations < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_settings_operations_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                data: { qa_selector: 'operations_settings_link' }
              }
            end

            override :active_routes
            def active_routes
              { controller: :operations }
            end

            override :item_name
            def item_name
              _('Operations')
            end

            override :render?
            def render?
              !context.project.archived? && can?(context.current_user, :admin_operations, context.project)
            end
          end
        end
      end
    end
  end
end
