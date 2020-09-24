# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Subscriptions::CreateService do
  subject { described_class.new(user, group: group, customer_params: customer_params, subscription_params: subscription_params) }

  let_it_be(:user) { create(:user, id: 111, first_name: 'First name', last_name: 'Last name', email: 'first.last@gitlab.com') }
  let_it_be(:group) { create(:group, id: 222, name: 'Group name') }

  let_it_be(:customer_params) do
    {
      country: 'NL',
      address_1: 'Address line 1',
      address_2: 'Address line 2',
      city: 'City',
      state: 'State',
      zip_code: 'Zip code',
      company: 'My organization'
    }
  end

  let_it_be(:subscription_params) do
    {
      plan_id: 'Plan ID',
      payment_method_id: 'Payment method ID',
      quantity: 123
    }
  end

  let_it_be(:client) { Gitlab::SubscriptionPortal::Client }
  let_it_be(:create_service_params) { Gitlab::Json.parse(fixture_file('create_service_params.json', dir: 'ee')).deep_symbolize_keys }

  describe '#execute' do
    context 'when failing to create a customer' do
      before do
        allow(client).to receive(:create_customer).and_return(success: false, data: { errors: 'failed to create customer' })
      end

      it 'returns the response hash' do
        expect(subject.execute).to eq(success: false, data: { errors: 'failed to create customer' })
      end
    end

    context 'when successfully creating a customer' do
      before do
        allow(client).to receive(:create_customer).and_return(success: true, data: { success: true, 'customer' => { 'authentication_token' => 'token' } })
      end

      it 'creates a subscription with the returned authentication token' do
        expect(client).to receive(:create_subscription).with(anything, user.email, 'token')
        subject.execute
      end

      context 'when failing to create a subscription' do
        before do
          allow(client).to receive(:create_subscription).and_return(success: false, data: { errors: 'failed to create subscription' })
        end

        it 'returns the response hash' do
          expect(subject.execute).to eq(success: false, data: { errors: 'failed to create subscription' })
        end
      end

      context 'when successfully creating a subscription' do
        before do
          allow(client).to receive(:create_subscription).and_return(success: true, data: { success: true, subscription_id: 'xxx' })
        end

        it 'returns the response hash' do
          expect(subject.execute).to eq(success: true, data: { success: true, subscription_id: 'xxx' })
        end
      end
    end

    context 'passing the correct parameters to the client' do
      before do
        allow(client).to receive(:create_customer).and_return(success: true, data: { success: true, customer: { authentication_token: 'token' } })
        allow(client).to receive(:create_subscription).and_return(success: true, data: { success: true, subscription_id: 'xxx' })
      end

      it 'passes the correct parameters for creating a customer' do
        expect(client).to receive(:create_customer).with(create_service_params[:customer])

        subject.execute
      end

      it 'passes the correct parameters for creating a subscription' do
        expect(client).to receive(:create_subscription).with(create_service_params[:subscription], 'first.last@gitlab.com', 'token')

        subject.execute
      end
    end
  end
end
