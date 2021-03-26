# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module SecurityCompliance
        module MenuItems
          class ThreatMonitoring < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_threat_monitoring_path(context.project)
            end

            override :active_routes
            def active_routes
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
