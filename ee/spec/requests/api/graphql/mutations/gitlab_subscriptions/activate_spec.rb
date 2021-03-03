# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Activate a subscription' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:admin) }

  let!(:application_setting) do
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
    create(:application_setting, cloud_license_enabled: true)
  end

  let(:authentication_token) { 'authentication_token' }
  let(:mutation) do
    graphql_mutation(:gitlab_subscription_activate, { activation_code: 'abc' })
  end

  let(:remote_response) do
    {
      success: true,
      data: {
        "data" => {
          "cloudActivationActivate" => {
            "authenticationToken" => authentication_token,
            "errors" => []
          }
        }
      }
    }
  end

  before do
    allow(Gitlab::SubscriptionPortal::Client).to receive(:http_post).and_return(remote_response)
  end

  it 'persists authentication token' do
    post_graphql_mutation(mutation, current_user: current_user)

    expect(response).to have_gitlab_http_status(:success)
    expect(graphql_mutation_response(:gitlab_subscription_activate)['errors']).to be_empty
    expect(application_setting.reload.cloud_license_auth_token).to eq(authentication_token)
  end
end
