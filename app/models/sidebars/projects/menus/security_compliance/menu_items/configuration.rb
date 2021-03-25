# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module SecurityCompliance
        module MenuItems
          class Configuration < ::Sidebars::MenuItem
            override :link_to_href
            def link_to_href
              project_security_configuration_path(context.project)
            end

            override :link_to_attributes
            def link_to_attributes
              {
                title: item_name,
                data: { qa_selector: 'security_configuration_link' }
              }
            end

            override :nav_link_params
            def nav_link_params
              { path: ['projects/security/configuration#show'] }
            end

            override :item_name
            def item_name
              _('Configuration')
            end

            override :render?
            def render?
              can?(context.current_user, :read_security_configuration, context.project)
            end
          end
        end
      end
    end
  end
end

Sidebars::Projects::Menus::SecurityCompliance::MenuItems::Configuration.prepend_if_ee('EE::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::Configuration')
