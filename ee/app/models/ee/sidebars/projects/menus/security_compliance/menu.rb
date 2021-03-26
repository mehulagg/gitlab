# frozen_string_literal: true

module EE
  module Sidebars
    module Projects
      module Menus
        module SecurityCompliance
          module Menu
            extend ::Gitlab::Utils::Override

            override :menu_link
            def menu_link
              # Depending on the items enabled,
              # the link and html attributes of the menu changes
              return selected_item.item_link if has_renderable_items?

              project_security_discover_path(context.project) if context.show_discover_project_security
            end

            override :extra_menu_container_html_options
            def extra_menu_container_html_options
              super[:data] = selected_item.extra_item_container_html_options[:data]
            end

            override :configure_menu_items
            def configure_menu_items
              super

              top_list_items[:dashboard] = ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::Dashboard.new(context)
              top_list_items[:audit_events] = ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::AuditEvents.new(context)
              top_list_items[:dependencies] = ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::DependencyList.new(context)

              insert_item_before(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::Configuration, top_list_items[:dashboard])
              insert_item_after(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::Dashboard, ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::VulnerabilityReport.new(context))
              insert_item_after(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::VulnerabilityReport, ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::OnDemandScans.new(context))
              insert_item_after(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::OnDemandScans, top_list_items[:dependencies])
              insert_item_after(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::DependencyList, ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::LicenseCompliance.new(context))
              insert_item_after(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::LicenseCompliance, ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::ThreatMonitoring.new(context))
              insert_item_after(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::ThreatMonitoring, ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::ScanPolicies.new(context))
              insert_item_after(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::Configuration, top_list_items[:audit_events])
            end

            private

            # This method selects which item is the one to retrieve info from
            # for the menu
            def selected_item
              @selected_item ||= begin
                return top_list_items[:dashboard] if top_list_items[:dashboard].render?
                return top_list_items[:audit_events] if top_list_items[:audit_events].render?

                top_list_items[:dependencies]
              end
            end

            def top_list_items
              @top_list_items ||= {}
            end
          end
        end
      end
    end
  end
end
