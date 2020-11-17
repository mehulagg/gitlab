# frozen_string_literal: true

module QA
  module Page
    module Main
      class FormlessLogin < Page::Base
        # This workaround avoids failure in Test::Sanity::Selectors
        # as it requires a Page class to have views / elements defined.
        view 'app/views/layouts/devise.html.haml'

        attr_accessor :path

        def initialize(as, address)
          user = as || Runtime::User
          self.path = "/users/qa_sign_in?user[login]=#{user.username}&user[password]=#{user.password}&gitlab_qa_formless_login_token=#{Runtime::Env.gitlab_qa_formless_login_token}"

          formless_login(address)
        end

        def formless_login(address)
          Runtime::Browser.visit(address, path)
        end
      end
    end
  end
end
