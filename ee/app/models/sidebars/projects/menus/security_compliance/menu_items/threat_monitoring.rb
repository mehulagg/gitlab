# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module SecurityCompliance
        module MenuItems
          class ThreatMonitoring < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              project_threat_monitoring_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: item_name
              }
            end

            override :nav_link_params
            def nav_link_params
              { controller: ['projects/threat_monitoring'] }
            end

            override :item_name
            def item_name
              _('Threat Monitoring')
            end

            override :render?
            def render?
              can?(context.current_user, :read_threat_monitoring, context.project)
            end
          end
        end
      end
    end
  end
end
