# frozen_string_literal: true

module QA
  RSpec.describe 'Manage' do
    describe 'personal access token' do

      let!(:user) do
        Resource::User.fabricate_via_api! do |resource|
          resource.api_client = Runtime::API::Client.as_admin
        end
      end

      it 'can be created via the API' do
        Flow::Login.sign_in

        token = Resource::PersonalAccessToken.fabricate_via_api! do |resource|
          resource.name = 'test-pat-via-api'
          resource.user = user
        end
      end
    end
  end
end
