# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Auth::Otp::Strategies::FortiAuthenticator do
  let_it_be(:user) { create(:user) }
  let(:otp_code) { 42 }

  let(:host) { 'forti_authenticator.example.com' }
  let(:port) { '444' }
  let(:api_username) { 'janedoe' }
  let(:api_token) { 's3cr3t' }

  let(:forti_authenticator_auth_url) { "https://#{host}:#{port}/api/v1/auth/" }
  let(:headers) { { 'Content-Type': 'application/json' } }
  let(:response_status) { 200 }
  let(:request_body) do
    { username: user.username,
      token_code: otp_code }
  end

  subject(:validate) { described_class.new(user).validate(otp_code) }

  before do
    stub_feature_flags(forti_authenticator: user)

    stub_forti_authenticator_config(
      enabled: true,
      host: host,
      port: port,
      username: api_username,
      access_token: api_token
    )

    stub_request(:post, forti_authenticator_auth_url)
      .with(body: JSON(request_body), headers: headers)
      .to_return(status: response_status, body: '', headers: headers)
  end

  context 'successful validation' do
    it 'returns success' do
      expect(Gitlab::HTTP).to(
        receive(:post)
          .with(forti_authenticator_auth_url,
                headers: headers,
                body: request_body.to_json,
                basic_auth: { username: api_username, password: api_token })
          .and_call_original
      )

      expect(validate[:status]).to eq(:success)
    end
  end

  context 'unsuccessful validation' do
    let(:response_status) { 401 }

    it 'returns error' do
      expect(validate[:status]).to eq(:error)
    end
  end

  context 'unexpected error' do
    it 'returns error' do
      error_message = 'boom!'
      allow(Gitlab::HTTP).to receive(:post).and_raise(error_message)

      expect(validate[:status]).to eq(:error)
      expect(validate[:message]).to eq(error_message)
    end
  end

  def stub_forti_authenticator_config(forti_authenticator_settings)
    allow(::Gitlab.config.forti_authenticator).to(receive_messages(forti_authenticator_settings))
  end
end
