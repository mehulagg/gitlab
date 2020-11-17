# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::API::Helpers do
  include Rack::Test::Methods

  let(:helper) do
    Class.new(Grape::API::Instance) do
      helpers EE::API::Helpers
      helpers API::APIGuard::HelperMethods
      helpers API::Helpers
      format :json

      get 'user' do
        current_user ? { id: current_user.id } : { found: false }
      end

      get 'protected' do
        authenticate_by_gitlab_geo_node_token!
      end
    end
  end

  def app
    helper
  end

  describe '#current_user' do
    let(:user) { build(:user, id: 42) }

    before do
      allow(Gitlab::Database::LoadBalancing).to receive(:enable?).and_return(true)
    end

    it 'handles sticking when a user could be found' do
      allow_any_instance_of(API::Helpers).to receive(:initial_current_user).and_return(user)

      expect(Gitlab::Database::LoadBalancing::RackMiddleware)
        .to receive(:stick_or_unstick).with(any_args, :user, 42)

      get 'user'

      expect(Gitlab::Json.parse(last_response.body)).to eq({ 'id' => user.id })
    end

    it 'does not handle sticking if no user could be found' do
      allow_any_instance_of(API::Helpers).to receive(:initial_current_user).and_return(nil)

      expect(Gitlab::Database::LoadBalancing::RackMiddleware)
        .not_to receive(:stick_or_unstick)

      get 'user'

      expect(Gitlab::Json.parse(last_response.body)).to eq({ 'found' => false })
    end

    it 'returns the user if one could be found' do
      allow_any_instance_of(API::Helpers).to receive(:initial_current_user).and_return(user)

      get 'user'

      expect(Gitlab::Json.parse(last_response.body)).to eq({ 'id' => user.id })
    end
  end

  describe '#authenticate_by_gitlab_geo_node_token!' do
    let(:invalid_geo_auth_header) { "#{::Gitlab::Geo::BaseRequest::GITLAB_GEO_AUTH_TOKEN_TYPE}...Test" }

    it 'rescues from ::Gitlab::Geo::InvalidDecryptionKeyError' do
      expect_any_instance_of(::Gitlab::Geo::JwtRequestDecoder).to receive(:decode) { raise ::Gitlab::Geo::InvalidDecryptionKeyError }

      header 'Authorization', invalid_geo_auth_header
      get 'protected', params: { current_user: 'test' }

      expect(Gitlab::Json.parse(last_response.body)).to eq({ 'message' => 'Gitlab::Geo::InvalidDecryptionKeyError' })
    end

    it 'rescues from ::Gitlab::Geo::InvalidSignatureTimeError' do
      allow_any_instance_of(::Gitlab::Geo::JwtRequestDecoder).to receive(:decode) { raise ::Gitlab::Geo::InvalidSignatureTimeError }

      header 'Authorization', invalid_geo_auth_header
      get 'protected', params: { current_user: 'test' }

      expect(Gitlab::Json.parse(last_response.body)).to eq({ 'message' => 'Gitlab::Geo::InvalidSignatureTimeError' })
    end

    it 'returns unauthorized response when scope is not valid' do
      allow_any_instance_of(::Gitlab::Geo::JwtRequestDecoder).to receive(:decode).and_return(scope: 'invalid_scope')

      header 'Authorization', 'test'
      get 'protected', params: { current_user: 'test' }

      expect(Gitlab::Json.parse(last_response.body)).to eq({ 'message' => '401 Unauthorized' })
    end
  end

  describe '#authorize_change_param' do
    subject { Class.new.include(described_class).new }

    let(:project) { create(:project) }

    before do
      allow(subject).to receive(:params).and_return({ change_commit_committer_check: true })
    end

    it 'does not throw exception if param is authorized' do
      allow(subject).to receive(:authorize!).and_return(nil)

      expect { subject.authorize_change_param(project, :change_commit_committer_check) }.not_to raise_error
    end

    context 'unauthorized param' do
      before do
        allow(subject).to receive(:authorize!).and_raise(Exception.new("Forbidden"))
      end
      it 'throws exception if unauthorized param is present' do
        expect { subject.authorize_change_param(project, :change_commit_committer_check) }.to raise_error
      end

      it 'does not throw exception is unauthorized param is not present' do
        expect { subject.authorize_change_param(project, :reject_unsigned_commit) }.not_to raise_error
      end
    end
  end
end
