module Page
  module Main
    class Entry < Page::Base
      def initialize
        visit('/')

        # This resolves cold boot problems with login page
        find('#tanuki-logo', wait: 60)
      end

      def sign_in_using_credentials
        if page.has_content?('Change your password', wait: 5)
          fill_in 'New password', with: 'test1234'
          fill_in 'Confirm new password', with: 'test1234'
          click_button 'Change your password'
        end

        fill_in 'Username or Email', with: 'root', wait: 5
        fill_in 'Password', with: 'test1234'
        click_button 'Sign in'
      end
    end
  end
end
