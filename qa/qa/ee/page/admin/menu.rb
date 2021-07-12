# frozen_string_literal: true

module QA
  module EE
    module Page
      module Admin
        module Menu
          extend QA::Page::PageConcern

          def self.prepended(base)
            super

            base.class_eval do
              view 'app/views/layouts/nav/sidebar/_admin.html.haml' do
                element :admin_settings_template_item
                element :admin_settings_advanced_search
              end

              view 'ee/app/views/layouts/nav/ee/admin/_geo_sidebar.html.haml' do
                element :link_geo_menu
              end

              view 'ee/app/views/layouts/nav/sidebar/_licenses_link.html.haml' do
                element :link_subscription_menu
              end

              view 'ee/app/views/layouts/nav/ee/admin/_new_monitoring_sidebar.html.haml' do
                element :admin_monitoring_audit_logs_link
              end
            end
          end

          def go_to_monitoring_audit_logs
            hover_element(:admin_monitoring_link) do
              within_submenu(:admin_sidebar_monitoring_submenu_content) do
                click_element :admin_monitoring_audit_logs_link
              end
            end
          end

          def click_geo_menu_link
            click_element :link_geo_menu
          end

          def click_subscription_menu_link
            click_element :link_subscription_menu
          end

          def go_to_template_settings
            hover_element(:admin_settings_item) do
              within_submenu(:admin_sidebar_settings_submenu_content) do
                click_element :admin_settings_template_item
              end
            end
          end

          def go_to_advanced_search
            hover_element(:admin_settings_item) do
              within_submenu(:admin_sidebar_settings_submenu_content) do
                click_element :admin_settings_advanced_search
              end
            end
          end
        end
      end
    end
  end
end
