# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module SecurityCompliance
        module MenuItems
          class ScanPolicies < ::Sidebars::MenuItem
            override :item_link
            def item_link
              project_security_policy_path(context.project)
            end

            override :active_routes
            def active_routes
              { controller: ['projects/security/policies'] }
            end

            override :item_name
            def item_name
              _('Scan Policies')
            end

            override :render?
            def render?
              can?(context.current_user, :security_orchestration_policies, context.project) &&
                Feature.enabled?(:security_orchestration_policies_configuration, context.project)
            end
          end
        end
      end
    end
  end
end
