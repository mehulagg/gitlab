# frozen_string_literal: true
require 'spec_helper'

RSpec.describe Gitlab::TerraformRegistryToken do
  let_it_be(:user) { create(:user) }
  let_it_be(:job) { create(:ci_build, user: user) }

  let(:deploy_token) do
    create(:deploy_token, username: 'deployer')
  end

  let(:personal_access_token) do
    create(:personal_access_token, user: user)
  end

  let(:jwt_from_deploy_token) do
    described_class.new(
      access_token_id: deploy_token.token,
      user_id: deploy_token.username
    )
  end

  let(:jwt_from_job_token) do
    described_class.new(
      access_token_id: job.token,
      user_id: job.user.id
    )
  end

  let(:jwt_from_personal_access_token) do
    described_class.new(
      access_token_id: personal_access_token.token,
      user_id: user.id
    )
  end

  describe '.from_token' do
    subject { described_class.decode(jwt_token.encoded) }

    context 'with a deploy token' do
      let(:jwt_token) { jwt_from_deploy_token }

      it 'returns the correct access_token_id' do
        expect(subject['access_token_id']).to eq jwt_token['access_token_id']
      end

      it 'returns the correct deploy token' do
        expect(subject.user).to eq deploy_token
      end
    end

    context 'with a job token' do
      let(:jwt_token) { jwt_from_job_token }

      it 'returns the correct access_token_id' do
        expect(subject['access_token_id']).to eq jwt_token['access_token_id']
      end

      it 'returns the correct user' do
        expect(subject.user).to eq job.user
      end
    end

    context 'with a personal access token' do
      let(:jwt_token) { jwt_from_personal_access_token }

      it 'returns the correct access_token_id' do
        expect(subject['access_token_id']).to eq jwt_token['access_token_id']
      end

      it 'returns the correct user' do
        expect(subject.user).to eq user
      end
    end
  end

  it_behaves_like 'a gitlab jwt token'
end
