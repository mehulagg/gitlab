# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module SecurityCompliance
        module MenuItems
          class Dashboard < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_security_dashboard_index_path(context.project)
            end

            override :extra_item_container_html_options
            def extra_item_container_html_options
              {
                data: { qa_selector: 'security_dashboard_link' }
              }
            end

            override :nav_link_params
            def nav_link_params
              { path: 'projects/security/dashboard#index' }
            end

            override :item_name
            def item_name
              _('Security Dashboard')
            end

            override :render?
            def render?
              can?(context.current_user, :read_project_security_dashboard, context.project)
            end
          end
        end
      end
    end
  end
end
