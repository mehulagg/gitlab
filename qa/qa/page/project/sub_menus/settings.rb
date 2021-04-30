# frozen_string_literal: true

module QA
  module Page
    module Project
      module SubMenus
        module Settings
          extend QA::Page::PageConcern

          def self.included(base)
            super

            base.class_eval do
              include QA::Page::Project::SubMenus::Common
            end
          end

          def go_to_ci_cd_settings
            hover_settings do
              within_submenu do
                click_link('CI/CD')
              end
            end
          end

          def go_to_repository_settings
            hover_settings do
              within_submenu do
                click_link('Repository')
              end
            end
          end

          def go_to_general_settings
            hover_settings do
              within_submenu do
                click_element(:sidebar_menu_item_link, menu_ite: 'General')
              end
            end
          end

          def click_settings
            within_sidebar do
              click_on 'Settings'
            end
          end

          def go_to_integrations_settings
            hover_settings do
              within_submenu do
                click_element(:sidebar_menu_item_link, menu_ite: 'Integrations')
              end
            end
          end

          def go_to_operations_settings
            hover_settings do
              within_submenu do
                click_element(:sidebar_menu_item_link, menu_ite: 'Operations')
              end
            end
          end

          def go_to_access_token_settings
            hover_settings do
              within_submenu do
                click_element(:sidebar_menu_item_link, menu_ite: 'Access Tokens')
              end
            end
          end

          private

          def hover_settings
            within_sidebar do
              scroll_to_element(:sidebar_menu_link, menu_ite: 'Settings')
              find_element(:sidebar_menu_link, menu_ite: 'Settings').hover

              yield
            end
          end
        end
      end
    end
  end
end
