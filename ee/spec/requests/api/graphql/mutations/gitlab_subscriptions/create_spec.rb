# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Create a subscription' do
  include GraphqlHelpers

  let(:mutation_name) { :gitlab_subscription_create }
  let_it_be(:current_user) { create(:admin) }
  let_it_be(:namespace) { create(:namespace, owner: current_user) }

  let(:customer) do
    {
      country: 'NL',
      address_1: 'Address line 1',
      address_2: 'Address line 2',
      city: 'City',
      state: 'State',
      zip_code: 'Zip code',
      company: 'My organization'
    }.to_json
  end

  let(:subscription) do
    {
      plan_id: 'abc',
      payment_method_id: 'payment_method_id',
      products: {
        main: {
          quantity: 1
        }
      },
      gl_namespace_id: namespace.id,
      gl_namespace_name: namespace.name,
      preview: 'false'
    }.to_json
  end

  let(:mutation_variables) do
    {
      namespace_id: namespace.to_gid.to_s,
      customer: customer,
      subscription: subscription
    }
  end

  let(:mutation) do
    graphql_mutation(mutation_name, mutation_variables)
  end

  let(:mutation_response) do
    graphql_mutation_response(mutation_name)&.with_indifferent_access
  end

  let(:result) do
    {
      success: true
    }
  end

  subject { post_graphql_mutation(mutation, current_user: current_user) }

  before do
    allow_next_instance_of(Subscriptions::CreateService) do |service|
      allow(service).to receive(:execute).and_return(result)
    end
  end

  context 'when feature flag is disabled' do
    before do
      stub_feature_flags(billings_purchase_subscription: false)
    end

    it_behaves_like 'a mutation that returns top-level errors', errors: ['billings_purchase_subscription feature is disabled']
  end

  context 'when feature flag is enabled' do
    before do
      stub_feature_flags(billings_purchase_subscription: true)
    end

    it 'send a request successfully' do
      post_graphql_mutation(mutation, current_user: current_user)
      subject

      expect(response).to have_gitlab_http_status(:success)
      expect(mutation_response[:errors]).to be_empty
    end

    context 'with invalid JSON' do
      let(:mutation_variables) do
        {
          namespace_id: namespace.to_gid.to_s,
          customer: 'invalid_json',
          subscription: subscription
        }
      end

      it_behaves_like 'an invalid argument to the mutation', argument_name: :customer
    end
  end
end
