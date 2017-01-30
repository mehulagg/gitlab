module QA
  module Page
    module Main
      class Entry < Page::Base
        def initialize
          visit('/')

          # This resolves cold boot problems with login page
          find('.application', wait: 120)
        end

        def sign_in_using_credentials
          if page.has_content?('Change your password')
            fill_in :user_password, with: Test::User.password
            fill_in :user_password_confirmation, with: Test::User.password
            click_button 'Change your password'
          end

          fill_in :user_login, with: Test::User.name
          fill_in :user_password, with: Test::User.password
          click_button 'Sign in'
        end
      end
    end
  end
end
