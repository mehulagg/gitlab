# frozen_string_literal: true

require 'date'

module QA
  module Resource
    class PersonalAccessToken < Base
      attr_accessor :name, :user

      attribute :name
      attribute :scopes
      attribute :user_id
      attribute :token do
        Page::Profile::PersonalAccessTokens.perform(&:created_access_token)
      end

      def fabricate_via_api!
        super
      end

      def api_post_path
        "/users/#{user.api_resource[:id]}/personal_access_tokens"
      end

      def api_get_path
        '/personal_access_tokens'
      end

      def api_post_body
        {
          name: name,
          scopes: ["api"]
        }
      end

      def resource_web_url(resource)
        super
      rescue ResourceURLMissingError
        # this particular resource does not expose a web_url property
      end

      def fabricate!
        Page::Main::Menu.perform(&:click_settings_link)
        Page::Profile::Menu.perform(&:click_access_tokens)

        Page::Profile::PersonalAccessTokens.perform do |token_page|
          token_page.fill_token_name(name || 'api-test-token')
          token_page.check_api
          # Expire in 2 days just in case the token is created just before midnight
          token_page.fill_expiry_date(Date.today + 2)
          token_page.click_create_token_button
        end
      end
    end
  end
end
