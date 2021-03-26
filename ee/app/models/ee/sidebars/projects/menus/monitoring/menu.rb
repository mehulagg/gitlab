# frozen_string_literal: true

module EE
  module Sidebars
    module Projects
      module Menus
        module Monitoring
          module Menu
            extend ::Gitlab::Utils::Override

            override :configure_menu_items
            def configure_menu_items
              super

              insert_item_after(::Sidebars::Projects::Menus::Monitoring::MenuItems::FeatureFlags, ::Sidebars::Projects::Menus::Monitoring::MenuItems::OnCallSchedules.new(context))
            end
          end
        end
      end
    end
  end
end
