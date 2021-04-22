# frozen_string_literal: true

module Sidebars
  module Projects
    module Menus
      module SecurityCompliance
        module MenuItems
          class Configuration < ::Sidebars::MenuItem
            override :link
            def link
              project_security_configuration_path(context.project)
            end

            override :active_routes
            def active_routes
              { path: ['projects/security/configuration#show'] }
            end

            override :title
            def title
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
