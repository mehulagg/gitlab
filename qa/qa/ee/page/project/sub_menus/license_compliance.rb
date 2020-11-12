# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module SubMenus
          module LicenseCompliance
            extend QA::Page::PageConcern

            def self.prepended(base)
              base.class_eval do
                view 'ee/app/views/layouts/nav/sidebar/_project_security_link.html.haml' do
                  element :licenses_list_link
                  element :security_dashboard_link
                end
              end
            end

            def click_on_license_compliance
              hover_security_compliance do
                within_submenu do
                  click_element(:licenses_list_link)
                end
              end
            end

            def hover_security_compliance
              within_sidebar do
                find_element(:security_dashboard_link).hover

                yield
              end
            end
          end
        end
      end
    end
  end
end
