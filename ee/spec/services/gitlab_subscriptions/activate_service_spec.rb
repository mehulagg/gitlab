# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSubscriptions::ActivateService do
  let(:application_settings) { Gitlab::CurrentSettings.current_application_settings }
  let(:authentication_token) { 'authentication_token' }
  let(:activation_code) { 'activation_code' }

  before do
    stub_env('IN_MEMORY_APPLICATION_SETTINGS', 'false')

    expect(Gitlab::SubscriptionPortal::Client).to receive(:activate)
      .with(activation_code)
      .and_return(response)
  end

  context 'when successful' do
    let(:response) { { success: true, authentication_token: authentication_token } }

    it 'persists authentication_token' do
      result = subject.execute(activation_code)

      expect(application_settings.reload.cloud_license_auth_token).to eq(authentication_token)
      expect(result).to eq(response)
    end
  end

  context 'when failure' do
    let(:response) { { success: false, errors: ['foo'] } }

    it 'returns error' do
      result = subject.execute(activation_code)

      expect(application_settings.reload.cloud_license_auth_token).to be_nil
      expect(result).to eq(response)
    end
  end
end
