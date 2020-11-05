# frozen_string_literal: true

module QA
  module Flow
    module SecureInstance
      module_function

      def disable_signups
        Flow::Login.sign_in_as_admin
        Page::Main::Menu.perform(&:go_to_admin_area)
        Page::Admin::Menu.perform(&:go_to_general_settings)

        Page::Admin::Settings::General.perform do |general_settings|
          general_settings.expand_signup_restrictions do |signup_settings|
            signup_settings.disable_signups
            signup_settings.save_changes
          end
        end
      end

      def change_root_password
        Flow::Login.sign_in_as_admin

      end
    end
  end
end

