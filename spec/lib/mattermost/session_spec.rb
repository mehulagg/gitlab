require 'spec_helper'

describe Mattermost::Session, type: :request do
  include ExclusiveLeaseHelpers

  let(:user) { create(:user) }

  let(:gitlab_url) { "http://gitlab.com" }
  let(:mattermost_url) { "http://mattermost.com" }

  subject { described_class.new(user) }

  # Needed for doorkeeper to function
  it { is_expected.to respond_to(:current_resource_owner) }
  it { is_expected.to respond_to(:request) }
  it { is_expected.to respond_to(:authorization) }
  it { is_expected.to respond_to(:strategy) }

  before do
    subject.base_uri = mattermost_url
  end

  describe '#with session' do
    let(:location) { 'http://location.tld' }
    let(:cookie_header) {'MMOAUTH=taskik8az7rq8k6rkpuas7htia; Path=/;'}
    let!(:stub) do
      WebMock.stub_request(:get, "#{mattermost_url}/oauth/gitlab/login")
        .to_return(headers: { 'location' => location, 'Set-Cookie' => cookie_header }, status: 302)
    end

    context 'without oauth uri' do
      it 'makes a request to the oauth uri' do
        expect { subject.with_session }.to raise_error(Mattermost::NoSessionError)
      end
    end

    context 'with oauth_uri' do
      let!(:doorkeeper) do
        Doorkeeper::Application.create(
          name: 'GitLab Mattermost',
          redirect_uri: "#{mattermost_url}/signup/gitlab/complete\n#{mattermost_url}/login/gitlab/complete",
          scopes: '')
      end

      context 'without token_uri' do
        it 'can not create a session' do
          expect do
            subject.with_session
          end.to raise_error(Mattermost::NoSessionError)
        end
      end

      context 'with token_uri' do
        let(:state) { "state" }
        let(:params) do
          { response_type: "code",
            client_id: doorkeeper.uid,
            redirect_uri: "#{mattermost_url}/signup/gitlab/complete",
            state: state }
        end
        let(:location) do
          "#{gitlab_url}/oauth/authorize?#{URI.encode_www_form(params)}"
        end

        before do
          WebMock.stub_request(:get, "#{mattermost_url}/signup/gitlab/complete")
            .with(query: hash_including({ 'state' => state }))
            .to_return do |request|
              post "/oauth/token",
                client_id: doorkeeper.uid,
                client_secret: doorkeeper.secret,
                redirect_uri: params[:redirect_uri],
                grant_type: 'authorization_code',
                code: request.uri.query_values['code']

              if response.status == 200
                { headers: { 'token' => 'thisworksnow' }, status: 202 }
              end
            end

          WebMock.stub_request(:post, "#{mattermost_url}/api/v4/users/logout")
            .to_return(headers: { Authorization: 'token thisworksnow' }, status: 200)
        end

        it 'can setup a session' do
          subject.with_session do |session|
          end

          expect(subject.token).not_to be_nil
        end

        it 'returns the value of the block' do
          result = subject.with_session do |session|
            "value"
          end

          expect(result).to eq("value")
        end
      end
    end

    context 'exclusive lease' do
      let(:lease_key) { 'mattermost:session' }

      it 'tries to obtain a lease' do
        expect_to_obtain_exclusive_lease(lease_key, 'uuid')
        expect_to_cancel_exclusive_lease(lease_key, 'uuid')

        # Cannot setup a session, but we should still cancel the lease
        expect { subject.with_session }.to raise_error(Mattermost::NoSessionError)
      end

      it 'returns a NoSessionError error without lease' do
        stub_exclusive_lease_taken(lease_key)

        expect { subject.with_session }.to raise_error(Mattermost::NoSessionError)
      end
    end
  end
end
