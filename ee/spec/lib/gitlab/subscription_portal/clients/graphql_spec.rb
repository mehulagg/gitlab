# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SubscriptionPortal::Clients::Graphql do
  include SubscriptionPortalHelpers

  let(:client) { Gitlab::SubscriptionPortal::Client }

  describe '#activate' do
    let(:license_key) { 'license_key' }

    it 'returns success' do
      expect(client).to receive(:execute_graphql_query).and_return(
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
      )

      result = client.activate('activation_code_abc')

      expect(result).to eq({ license_key: license_key, success: true })
    end

    it 'returns failure' do
      expect(client).to receive(:execute_graphql_query).and_return(
        {
          success: true,
          data: {
            "data" => {
              "cloudActivationActivate" => {
                "licenseKey" => nil,
                "errors" => ["invalid activation code"]
              }
            }
          }
        }
      )

      result = client.activate('activation_code_abc')

      expect(result).to eq({ errors: ["invalid activation code"], success: false })
    end
  end

  describe '#plan_upgrade_offer' do
    let(:namespace_id) { 111 }

    subject(:plan_upgrade_offer) { client.plan_upgrade_offer(namespace_id: namespace_id) }

    context 'when the response contains errors' do
      before do
        expect(client).to receive(:execute_graphql_query).and_return(response)
      end

      let(:response) do
        {
          success: true,
          data: {
            'errors' => [{ 'message' => 'this will be ignored' }]
          }
        }
      end

      it 'returns a failure' do
        expect(plan_upgrade_offer).to eq({ success: false })
      end
    end

    context 'when the response does not contain errors' do
      using RSpec::Parameterized::TableSyntax

      where(:eligible, :assisted_plan_id, :free_plan_id) do
        true | '111111' | '111111'
        true | '111111' | nil
        true | nil      | '111111'
      end

      with_them do
        before do
          allow(client).to receive(:execute_graphql_query).and_return({
              success: true,
              data: { "data" => { "subscription" => {
                "eoaStarterBronzeEligible" => eligible,
                "assistedUpgradePlanId" => assisted_plan_id,
                "freeUpgradePlanId" => free_plan_id
                } } }
          })
        end

        it 'returns the correct response' do
          expect(plan_upgrade_offer).to eq({
            success: true,
            eligible_for_free_upgrade: eligible,
            assisted_upgrade_plan_id: assisted_plan_id,
            free_upgrade_plan_id: free_plan_id
          })
        end
      end

      context 'when subscription is nil' do
        before do
          allow(client).to receive(:execute_graphql_query).and_return({
            success: true,
            data: { "data" => { "subscription" => nil } }
          })
        end

        it 'returns the correct response' do
          expect(plan_upgrade_offer).to eq({
            success: true,
            eligible_for_free_upgrade: nil,
            assisted_upgrade_plan_id: nil,
            free_upgrade_plan_id: nil
          })
        end
      end
    end
  end

  describe '#plan_data' do
    let(:plan_tags) { 'CI_1000_MINUTES_PLAN' }

    subject(:plan_data) { client.plan_data(plan_tags, stubbed_plan_data_query_fields) }

    context 'when the response contains errors' do
      before do
        expect(client).to receive(:execute_graphql_query).and_return(response)
      end

      let(:response) do
        {
          success: true,
          data: {
            'errors' => [{ 'message' => 'this will be ignored' }]
          }
        }
      end

      it 'logs an error and returns a failure' do
        expect(Gitlab::ErrorTracking)
          .to receive(:track_and_raise_for_dev_exception)
          .with(
            a_kind_of(Gitlab::SubscriptionPortal::Client::ResponseError),
          query: include(*stubbed_plan_data_query_fields_camelized), response: response[:data])

        expect(plan_data).to eq({ success: false })
      end
    end

    context 'when the response does not contain errors' do
      before do
        allow(client).to receive(:execute_graphql_query).and_return({ data: Gitlab::Json.parse(stubbed_plan_data_response_body) })
      end

      it 'filters out the deprecated plans' do
        expect(plan_data).to match({
          success: true,
          plans: contain_exactly(include('deprecated' => false))
        })
      end

      context 'when plans is an empty array' do
        before do
          allow(client).to receive(:execute_graphql_query).and_return({
            success: true,
            data: { "data" => { "plans" => [] } }
          })
        end

        it 'returns the correct response' do
          expect(plan_data).to eq({ success: true, plans: [] })
        end
      end
    end
  end

  describe '#subscription_last_term' do
    let(:query) do
      <<~GQL
        query($namespaceId: ID!) {
          subscription(namespaceId: $namespaceId) {
            lastTerm
          }
        }
      GQL
    end

    it 'returns success' do
      expected_args = {
        query: query,
        variables: {
          namespaceId: 'namespace-id'
        }
      }

      expected_response = {
        success: true,
        data: {
          "data" => {
            "subscription" => {
              "lastTerm" => true
            }
          }
        }
      }

      expect(client).to receive(:execute_graphql_query).with(expected_args).and_return(expected_response)

      result = client.subscription_last_term('namespace-id')

      expect(result).to eq({ success: true, last_term: true })
    end

    it 'returns failure' do
      error = "some error"
      expect(client).to receive(:execute_graphql_query).and_return(
        {
          success: false,
          data: {
            errors: error
          }
        }
      )

      result = client.subscription_last_term('failing-namespace-id')

      expect(result).to eq({ success: false, errors: error })
    end

    context 'with no namespace_id' do
      it 'returns failure' do
        expect(client).not_to receive(:execute_graphql_query)

        expect(client.subscription_last_term(nil)).to eq({ success: false, errors: 'Must provide a namespace ID' })
      end
    end
  end
end
