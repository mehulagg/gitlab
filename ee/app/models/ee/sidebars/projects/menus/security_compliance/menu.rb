# frozen_string_literal: true

module EE
  module Sidebars
    module Projects
      module Menus
        module SecurityCompliance
          module Menu
            extend ::Gitlab::Utils::Override

            override :link_to_href
            def link_to_href
              # TODO This elements catches the link from the first element displayed
              # We should iterate over all renderable items and return the first link
              # project_security_configuration_path(context.project)
              if !has_renderable_items? && context.show_discover_project_security
                project_security_discover_path(context.project)
              end
            end

            # override :link_to_attributes
            # def link_to_attributes
            #   {
            #     data: { qa_selector: 'audit_events_settings_link' }
            #   }
            # end

            override :configure_menu_items
            def configure_menu_items
              super

              insert_item_before(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::Configuration, ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::Dashboard.new(context))
              insert_item_after(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::Dashboard, ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::VulnerabilityReport.new(context))
              insert_item_after(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::VulnerabilityReport, ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::OnDemandScans.new(context))
              insert_item_after(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::OnDemandScans, ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::DependencyList.new(context))
              insert_item_after(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::DependencyList, ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::LicenseCompliance.new(context))
              insert_item_after(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::LicenseCompliance, ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::ThreatMonitoring.new(context))
              insert_item_after(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::ThreatMonitoring, ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::ScanPolicies.new(context))
              add_item(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::AuditEvents.new(context))
            end

            private

            # def selected_menu
            #   dashboard_menu = renderable_items.find { |i| it.is_a?(::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::Dashboard) }

            #   [
            #    ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::AuditEvents
            #    ::Sidebars::Projects::Menus::SecurityCompliance::MenuItems::DependencyList].each do |menu_type|
            #     renderable_items.select do |item|
            #       item.is_a?()
            #     end
            #   end
            # end

            # def top_level_link(project)
            #   return project_security_dashboard_index_path(project) if project_nav_tab?(:security)
            #   return project_audit_events_path(project) if project_nav_tab?(:audit_events)

            #   project_dependencies_path(project)
            # end

            # def top_level_qa_selector(project)
            #   return 'security_dashboard_link' if project_nav_tab?(:security)
            #   return 'audit_events_settings_link' if project_nav_tab?(:audit_events)

            #   'dependency_list_link'
            # end
          end
        end
      end
    end
  end
end

