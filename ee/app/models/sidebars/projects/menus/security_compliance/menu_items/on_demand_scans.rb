# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module SecurityCompliance
        module MenuItems
          class OnDemandScans < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              new_project_on_demand_scan_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: item_name,
                data: { qa_selector: 'on_demand_scans_link' }
              }
            end

            override :nav_link_params
            def nav_link_params
              { path: %w[
                  projects/on_demand_scans#index
                  projects/on_demand_scans#new
                  projects/on_demand_scans#edit
                ] }
            end

            override :item_name
            def item_name
              s_('OnDemandScans|On-demand Scans')
            end

            override :render?
            def render?
              can?(context.current_user, :read_on_demand_scans, context.project)
            end
          end
        end
      end
    end
  end
end
