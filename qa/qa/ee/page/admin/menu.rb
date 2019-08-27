# frozen_string_literal: true

module QA
  module EE
    module Page
      module Admin
        module Menu
          def self.prepended(page)
            page.module_eval do
              view 'app/views/layouts/nav/sidebar/_admin.html.haml' do
                element :admin_settings_template_item
              end

              view 'ee/app/views/layouts/nav/ee/admin/_geo_sidebar.html.haml' do
                element :link_geo_menu
              end

              view 'ee/app/views/layouts/nav/sidebar/_licenses_link.html.haml' do
                element :link_license_menu
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

          def go_to_elasticsearch_settings
            hover_elasticsearch do
              within_submenu do
                click_element :admin_elasticsearch_settings_item
              end
            end
          end

          def go_to_elasticsearch_index
            hover_elasticsearch do
              within_submenu do
                click_element :admin_elasticsearch_index_item
              end
            end
          end

          def hover_elasticsearch
            within_sidebar do
              scroll_to_element(:admin_elasticsearch_item)
              find_element(:admin_elasticsearch_item).hover

              yield
            end
          end

          def click_license_menu_link
            click_element :link_license_menu
          end

          def go_to_template_settings
            hover_element(:admin_settings_item) do
              within_submenu(:admin_sidebar_settings_submenu) do
                click_element :admin_settings_template_item
              end
            end
          end
        end
      end
    end
  end
end
