# frozen_string_literal: true

require 'date'

module QA
  module Resource
    class ProjectAccessToken < Base
      attr_accessor :name

      attribute :project do
        Project.fabricate!
      end

      attribute :token do
        Page::Project::Settings::AccessTokens.perform(&:created_access_token)
      end

      def resource_web_url(resource)
        super
      rescue ResourceURLMissingError
        # this particular resource does not expose a web_url property
      end

      def fabricate!
        Flow::Login.sign_in_unless_signed_in

        project.visit!

        Page::Project::Menu.perform(&:go_to_access_token_settings)

        Page::Project::Settings::AccessTokens.perform do |token_page|
          token_page.fill_token_name(name || 'api-project-access-token')
          token_page.check_api
          # Expire in 2 days just in case the token is created just before midnight
          token_page.fill_expiry_date(Time.now.utc.to_date + 2)
          token_page.click_create_token_button
        end
      end
    end
  end
end
