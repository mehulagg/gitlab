# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::ActivateService do
  let!(:application_settings) do
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')
    create(:application_setting, cloud_license_enabled: cloud_license_enabled)
  end

  let(:cloud_license_enabled) { true }
  let(:authentication_token) { 'authentication_token' }
  let(:activation_code) { 'activation_code' }

  def stub_client_activate
    expect(Gitlab::SubscriptionPortal::Client).to receive(:activate)
      .with(activation_code)
      .and_return(response)
  end

  before do
    allow(Gitlab::CurrentSettings).to receive(:current_application_settings).and_return(application_settings)
  end

  context 'when CustomerDot returns success' do
    let(:response) { { success: true, authentication_token: authentication_token } }

    before do
      stub_client_activate
    end

    it 'persists authentication_token' do
      expect(subject.execute(activation_code)).to eq(response)

      expect(application_settings.reload.cloud_license_auth_token).to eq(authentication_token)
    end

    context 'when persisting fails' do
      let(:response) { { success: true, authentication_token: authentication_token } }

      it 'returns error' do
        application_settings.errors.add(:base, :invalid)
        allow(application_settings).to receive(:update).and_return(false)

        expect(subject.execute(activation_code)).to eq({ errors: ["is invalid"], success: false })
      end
    end
  end

  context 'when CustomerDot returns failure' do
    let(:response) { { success: false, errors: ['foo'] } }

    it 'returns error' do
      stub_client_activate

      expect(subject.execute(activation_code)).to eq(response)

      expect(application_settings.reload.cloud_license_auth_token).to be_nil
    end
  end

  context 'when not self managed instance' do
    let(:response) { { success: false, errors: [described_class::ERROR_MESSAGES[:not_self_managed]] }}

    it 'returns error' do
      allow(Gitlab).to receive(:com?).and_return(true)
      expect(Gitlab::SubscriptionPortal::Client).not_to receive(:activate)

      expect(subject.execute(activation_code)).to eq(response)
    end
  end

  context 'when cloud licensing disabled' do
    let(:response) { { success: false, errors: [described_class::ERROR_MESSAGES[:disabled]] }}
    let(:cloud_license_enabled) { false }

    it 'returns error' do
      expect(Gitlab::SubscriptionPortal::Client).not_to receive(:activate)

      expect(subject.execute(activation_code)).to eq(response)
    end
  end

  context 'when error is raised' do
    it 'captures error' do
      expect(Gitlab::SubscriptionPortal::Client).to receive(:activate).and_raise('foo')

      expect(subject.execute(activation_code)).to eq({ success: false, errors: ['foo'] })
    end
  end
end
