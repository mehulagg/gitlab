# frozen_string_literal: true

module QA
  module EE
    module Page
      module Group
        class Members < QA::Page::Base
          view 'ee/app/views/groups/group_members/_sync_button.html.haml' do
            element :sync_now_button
          end

          view 'ee/app/helpers/groups/ldap_sync_helper.rb' do
            element :sync_ldap_confirm_button
          end

          def click_sync_now
            QA::Runtime::Logger.info " "
            screenshot_file = ::File.join(QA::Runtime::Namespace.name, "#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}-click_sync_now.png")
            QA::Runtime::Logger.info ">>>>>> saving screenshot to file: #{screenshot_file}"
            QA::Runtime::Logger.info page.save_screenshot(screenshot_file, full: true)
            QA::Runtime::Logger.info " "

            click_element :sync_now_button
            click_element :sync_ldap_confirm_button
          end
        end
      end
    end
  end
end
