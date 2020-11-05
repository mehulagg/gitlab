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

      def change_password_for_tunnel
        Flow::Login.sign_in_as_admin
        Page::Main::Menu.perform(&:click_settings_link)
        Page::Profile::Menu.perform(&:click_password)

        Page::Profile::Password.perform do |password_page|
          password_page.update_password(Runtime::User.admin_tunnel_password, Runtime::User.admin_password)
        end
      end
    end
  end
end

