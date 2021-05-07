# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::ActivateService do
  subject(:execute_service) { described_class.new.execute(activation_code) }

  let!(:application_settings) do
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
    create(:application_setting, cloud_license_enabled: cloud_license_enabled)
  end

  let_it_be(:license_key) { build(:gitlab_license).export }
  let(:cloud_license_enabled) { true }
  let(:activation_code) { 'activation_code' }

  def stub_client_activate
    expect(Gitlab::SubscriptionPortal::Client).to receive(:activate)
      .with(activation_code)
      .and_return(customer_dot_response)
  end

  before do
    allow(Gitlab::CurrentSettings).to receive(:current_application_settings).and_return(application_settings)
  end

  context 'when CustomerDot returns success' do
    let(:customer_dot_response) { { success: true, license_key: license_key } }

    before do
      stub_client_activate
    end

    it 'persists license' do
      result = execute_service
      created_license = License.last

      expect(result).to eq({ success: true, license: created_license })

      expect(created_license.data).to eq(license_key)
    end

    context 'when persisting fails' do
      let(:license_key) { 'invalid key' }

      it 'returns error' do
        expect(execute_service).to match({ errors: [be_a_kind_of(String)], success: false })
      end
    end
  end

  context 'when CustomerDot returns failure' do
    let(:customer_dot_response) { { success: false, errors: ['foo'] } }

    it 'returns error' do
      stub_client_activate

      expect(execute_service).to eq(customer_dot_response)

      expect(License.last&.data).not_to eq(license_key)
    end
  end

  context 'when not self managed instance' do
    let(:customer_dot_response) { { success: false, errors: [described_class::ERROR_MESSAGES[:not_self_managed]] }}

    it 'returns error' do
      allow(Gitlab).to receive(:com?).and_return(true)
      expect(Gitlab::SubscriptionPortal::Client).not_to receive(:activate)

      expect(execute_service).to eq(customer_dot_response)
    end
  end

  context 'when cloud licensing disabled' do
    let(:customer_dot_response) { { success: false, errors: [described_class::ERROR_MESSAGES[:disabled]] }}
    let(:cloud_license_enabled) { false }

    it 'returns error' do
      expect(Gitlab::SubscriptionPortal::Client).not_to receive(:activate)

      expect(execute_service).to eq(customer_dot_response)
    end
  end

  context 'when error is raised' do
    it 'captures error' do
      expect(Gitlab::SubscriptionPortal::Client).to receive(:activate).and_raise('foo')

      expect(execute_service).to eq({ success: false, errors: ['foo'] })
    end
  end
end
