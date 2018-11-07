require 'spec_helper'

describe Gitlab::Geo::OauthSession do
  subject { described_class.new }
  let(:oauth_app) { FactoryBot.create(:doorkeeper_application) }
  let(:oauth_return_to) { 'http://secondary/oauth/geo/callback' }
  let(:dummy_state) { 'salt:hmac:return_to' }
  let(:valid_state) { described_class.new(return_to: oauth_return_to).generate_oauth_state }
  let(:access_token) { FactoryBot.create(:doorkeeper_access_token).token }

  before do
    allow(subject).to receive(:oauth_app) { oauth_app }
    allow(subject).to receive(:primary_node_url) { 'http://primary/' }
  end

  describe '#oauth_state_valid?' do
    it 'returns false when state is not present' do
      expect(subject.oauth_state_valid?).to be_falsey
    end

    it 'returns false when return_to cannot be retrieved' do
      subject.state = 'invalidstate'
      expect(subject.oauth_state_valid?).to be_falsey
    end

    it 'returns false when hmac does not match' do
      subject.state = dummy_state
      expect(subject.oauth_state_valid?).to be_falsey
    end

    it 'returns true when hmac matches generated one' do
      subject.state = valid_state
      expect(subject.oauth_state_valid?).to be_truthy
    end
  end

  describe '#generate_oauth_state' do
    it 'returns nil when return_to is not present' do
      expect(subject.generate_oauth_state).to be_nil
    end

    context 'when return_to is present' do
      it 'returns a string' do
        expect(valid_state).to be_a String
        expect(valid_state).not_to be_empty
      end

      it 'includes return_to value' do
        expect(valid_state).to include(oauth_return_to)
      end
    end
  end

  describe '#get_oauth_state_return_to' do
    it 'returns return_to value' do
      subject = described_class.new(state: valid_state)

      expect(subject.get_oauth_state_return_to).to eq(oauth_return_to)
    end
  end

  describe '#get_oauth_state_return_to_full_path' do
    it 'removes the domain from return_to value' do
      subject = described_class.new(state: valid_state)

      expect(subject.get_oauth_state_return_to_full_path).to eq('/oauth/geo/callback')
    end
  end

  describe '#generate_logout_state' do
    it 'returns nil when access_token is not defined' do
      expect(described_class.new.generate_logout_state).to be_nil
    end

    it 'returns false when encryptation fails' do
      allow_any_instance_of(OpenSSL::Cipher::AES)
        .to receive(:final) { raise OpenSSL::OpenSSLError }

      expect(subject.generate_logout_state).to be_falsey
    end

    it 'returns a string with salt, encrypted access token, and return_to colon separated' do
      subject = described_class.new(access_token: access_token, return_to: oauth_return_to)

      state = subject.generate_logout_state
      expect(state).to be_a String
      expect(state).not_to be_blank

      salt, encrypted, return_to = state.split(':', 3)
      expect(salt).not_to be_blank
      expect(encrypted).not_to be_blank
      expect(return_to).not_to be_blank
    end

    it 'include a empty value for return_to into state when return_to param is not defined' do
      subject = described_class.new(access_token: access_token)

      state = subject.generate_logout_state
      _, _, return_to = state.split(':', 3)

      expect(return_to).to eq ''
    end

    it 'does not include the host from return_to param into into the state' do
      subject = described_class.new(access_token: access_token, return_to: oauth_return_to)

      state = subject.generate_logout_state
      _, _, return_to = state.split(':', 3)

      expect(return_to).to eq '/oauth/geo/callback'
    end
  end

  describe '#extract_logout_token' do
    subject { described_class.new(access_token: access_token) }

    it 'returns nil when state is not defined' do
      expect(subject.extract_logout_token).to be_nil
    end

    it 'returns nil when state is empty' do
      subject.state = ''

      expect(subject.extract_logout_token).to be_nil
    end

    it 'returns false when decryptation fails' do
      allow_any_instance_of(OpenSSL::Cipher::AES)
        .to receive(:final) { raise OpenSSL::OpenSSLError }

      expect(subject.extract_logout_token).to be_falsey
    end

    it 'encrypted access token is recoverable' do
      subject.generate_logout_state

      access_token = subject.extract_logout_token
      expect(access_token).to eq access_token
    end
  end

  describe '#authorized_url' do
    subject { described_class.new(return_to: oauth_return_to) }

    it 'returns a valid url' do
      expect(subject.authorize_url).to be_a String
      expect(subject.authorize_url).to include('http://primary/')
    end
  end

  describe '#authenticate_with_gitlab' do
    let(:api_url) { 'http://primary/api/v4/user' }
    let(:user_json) { ActiveSupport::JSON.encode({ id: 555, email: 'user@example.com' }.as_json) }

    context 'on success' do
      before do
        stub_request(:get, api_url).to_return(
          body: user_json,
          headers: { 'Content-Type' => 'application/json' }
        )
      end

      it 'returns hashed user data' do
        parsed_json = JSON.parse(user_json)

        expect(subject.authenticate_with_gitlab(access_token)).to eq(parsed_json)
      end
    end

    context 'on invalid token' do
      before do
        stub_request(:get, api_url).to_return(status: [401, "Unauthorized"])
      end

      it 'raises exception' do
        expect { subject.authenticate_with_gitlab(access_token) }.to raise_error(OAuth2::Error)
      end
    end
  end
end
