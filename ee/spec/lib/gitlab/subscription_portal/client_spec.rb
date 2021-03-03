# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::SubscriptionPortal::Client do
  let(:http_response) { nil }
  let(:httparty_response) do
    double(code: http_response.code, response: http_response, body: {}, parsed_response: {})
  end

  let(:http_method) { :post }

  shared_examples 'when response is successful' do
    let(:http_response) { Net::HTTPSuccess.new(1.0, '201', 'OK') }

    it 'has a successful status' do
      allow(Gitlab::HTTP).to receive(http_method).and_return(httparty_response)

      expect(subject[:success]).to eq(true)
    end
  end

  shared_examples 'when response code is 422' do
    let(:http_response) { Net::HTTPUnprocessableEntity.new(1.0, '422', 'Error') }

    it 'has a unprocessable entity status' do
      allow(Gitlab::HTTP).to receive(http_method).and_return(httparty_response)

      expect(subject[:success]).to eq(false)
    end
  end

  shared_examples 'when response code is 500' do
    let(:http_response) { Net::HTTPServerError.new(1.0, '500', 'Error') }

    it 'has a server error status' do
      allow(Gitlab::HTTP).to receive(http_method).and_return(httparty_response)

      expect(subject[:success]).to eq(false)
    end
  end

  describe '#create_trial_account' do
    subject do
      described_class.generate_trial({})
    end

    it_behaves_like 'when response is successful'
    it_behaves_like 'when response code is 422'
    it_behaves_like 'when response code is 500'
  end

  describe '#create_subscription' do
    subject do
      described_class.create_subscription({}, 'customer@mail.com', 'token')
    end

    it_behaves_like 'when response is successful'
    it_behaves_like 'when response code is 422'
    it_behaves_like 'when response code is 500'
  end

  describe '#create_customer' do
    subject do
      described_class.create_customer({})
    end

    it_behaves_like 'when response is successful'
    it_behaves_like 'when response code is 422'
    it_behaves_like 'when response code is 500'
  end

  describe '#payment_form_params' do
    subject do
      described_class.payment_form_params('cc')
    end

    let(:http_method) { :get }

    it_behaves_like 'when response is successful'
    it_behaves_like 'when response code is 422'
    it_behaves_like 'when response code is 500'
  end

  describe '#payment_method' do
    subject do
      described_class.payment_method('1')
    end

    let(:http_method) { :get }

    it_behaves_like 'when response is successful'
    it_behaves_like 'when response code is 422'
    it_behaves_like 'when response code is 500'
  end

  describe '#activate' do
    let(:authentication_token) { 'authentication_token' }

    it 'returns success' do
      expect(described_class).to receive(:http_post).and_return(
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
      )

      result = described_class.activate('activation_code_abc')

      expect(result).to eq({ authentication_token: authentication_token, success: true })
    end

    it 'returns failure' do
      expect(described_class).to receive(:http_post).and_return(
        {
          success: true,
          data: {
            "data" => {
              "cloudActivationActivate" => {
                "authenticationToken" => nil,
                "errors" => ["invalid activation code"]
              }
            }
          }
        }
      )

      result = described_class.activate('activation_code_abc')

      expect(result).to eq({ errors: ["invalid activation code"], success: false })
    end
  end

  describe '#plan_upgrade_offer' do
    let(:namespace_id) { 111 }
    let(:headers) do
      {
        "Accept" => "application/json",
        "Content-Type" => "application/json",
        "X-Admin-Email" => "gl_com_api@gitlab.com",
        "X-Admin-Token" => "customer_admin_token"
      }
    end

    let(:params) do
      { query: <<~GQL
        {
          subscription(namespaceId: "{:namespace_id=>#{namespace_id}}") {
            eoaStarterBronzeEligible
            assistedUpgradePlanId
            freeUpgradePlanId
          }
        }
      GQL
      }
    end

    subject(:plan_upgrade_offer) { described_class.plan_upgrade_offer(namespace_id: namespace_id) }

    context 'when the response contains errors' do
      before do
        expect(described_class).to receive(:http_post).with('graphql', headers, params).and_return(response)
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
          allow(described_class).to receive(:http_post).and_return({
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
          allow(described_class).to receive(:http_post).and_return({
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
end
