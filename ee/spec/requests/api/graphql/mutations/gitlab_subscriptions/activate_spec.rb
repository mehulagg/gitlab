# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Activate a subscription' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:admin) }
  let_it_be(:license_key) { build(:gitlab_license).export }
  let(:activation_code) { 'activation_code' }
  let(:mutation) do
    graphql_mutation(:gitlab_subscription_activate, { activation_code: activation_code })
  end

  let!(:application_setting) do
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
    create(:application_setting, cloud_license_enabled: true)
  end

  let(:remote_response) do
    {
      success: true,
      data: {
        "data" => {
          "cloudActivationActivate" => {
            "licenseKey" => license_key,
            "errors" => []
          }
        }
      }
    }
  end

  it 'persists license key' do
    expect(Gitlab::SubscriptionPortal::Client)
      .to receive(:execute_graphql_query)
      .with({
        query: an_instance_of(String),
        variables: {
          activationCode: activation_code,
          instanceIdentifier: application_setting.uuid
        }
      })
      .and_return(remote_response)

    post_graphql_mutation(mutation, current_user: current_user)

    expect(response).to have_gitlab_http_status(:success)
    expect(graphql_mutation_response(:gitlab_subscription_activate)['errors']).to be_empty
    expect(License.last.data).to eq(license_key)
  end
end
