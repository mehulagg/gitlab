# frozen_string_literal: true

module QA
  module Flow
    module Login
      module_function

      def while_signed_in(as: nil, address: :gitlab)
        Page::Main::Menu.perform(&:sign_out_if_signed_in)

        sign_in(as: as, address: address)

        yield

        Page::Main::Menu.perform(&:sign_out)
      end

      def while_signed_in_as_admin(address: :gitlab)
        while_signed_in(as: Runtime::User.admin, address: address) do
          yield
        end
      end

      def sign_in(as: nil, address: :gitlab)
        Runtime::Browser.visit(address, Page::Main::Login)
        Page::Main::Login.perform { |login| login.sign_in_using_credentials(user: as) }
      end

      def formless_login(user: nil, use_blank_page: false)
        # Login can be made from a blank page Otherwise the javascript gets injected in the current one.
        if use_blank_page
          Runtime::Browser.visit(:gitlab, Page::Main::FormlessLogin)
        end

        login_as = user || Runtime::User.admin

        Capybara.current_session.driver.execute_script(
          <<~JS
            var form = document.createElement('form');
            form.action = '/users/qa_sign_in';
            form.method = 'POST';
            var username = document.createElement('input');
            username.name = 'user[login]';
            username.value = "#{login_as.username}";;
            form.appendChild(username);
            var password = document.createElement('input');
            password.name = 'user[password]';
            password.value = "#{login_as.password}";
            form.appendChild(password);
            document.body.appendChild(form);
            form.submit();
          JS
        )
      end

      def sign_in_as_admin(address: :gitlab)
        sign_in(as: Runtime::User.admin, address: address)
      end

      def sign_in_unless_signed_in(as: nil, address: :gitlab)
        sign_in(as: as, address: address) unless Page::Main::Menu.perform(&:signed_in?)
      end
    end
  end
end
