# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module SecurityCompliance
        module MenuItems
          class Dashboard < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              project_security_dashboard_index_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: item_name,
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
