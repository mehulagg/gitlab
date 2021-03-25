# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module SecurityCompliance
        module MenuItems
          class ScanPolicies < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              project_security_policy_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: item_name
              }
            end

            override :nav_link_params
            def nav_link_params
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
