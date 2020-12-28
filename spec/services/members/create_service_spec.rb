# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Members::CreateService, :clean_gitlab_redis_shared_state do
  let_it_be(:source) { create(:project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:member) { create(:user) }
  let_it_be(:user_ids) { member.id.to_s }
  let_it_be(:access_level) { Gitlab::Access::GUEST }
  let(:params) { { user_ids: user_ids, access_level: access_level } }

  subject(:execute_service) { described_class.new(user, params).execute(source) }

  before do
    source.is_a?(Project) ? source.add_maintainer(user) : source.add_owner(user)
  end

  context 'when passing valid parameters' do
    it 'adds a user to members' do
      expect(execute_service[:status]).to eq(:success)
      expect(source.users).to include member
      expect(Namespaces::OnboardingUserAddedWorker.jobs.last['args'][0]).to eq(source.namespace_id)
    end

    context 'when executing on a group' do
      let_it_be(:source) { create(:group) }

      it 'adds a user to members' do
        expect(execute_service[:status]).to eq(:success)
        expect(source.users).to include member
        expect(Namespaces::OnboardingUserAddedWorker.jobs.last['args'][0]).to eq(source.id)
      end
    end
  end

  context 'when passing no user ids' do
    let(:user_ids) { '' }

    it 'does not add a member' do
      expect(execute_service[:status]).to eq(:error)
      expect(execute_service[:message]).to be_present
      expect(source.users).not_to include member
      expect(Namespaces::OnboardingUserAddedWorker.jobs.size).to eq(0)
    end
  end

  context 'when passing many user ids' do
    let(:user_ids) { 1.upto(101).to_a.join(',') }

    it 'limits the number of users to 100' do
      expect(execute_service[:status]).to eq(:error)
      expect(execute_service[:message]).to be_present
      expect(source.users).not_to include member
      expect(Namespaces::OnboardingUserAddedWorker.jobs.size).to eq(0)
    end
  end

  context 'when passing an invalid access level' do
    let(:access_level) { -1 }

    it 'does not add a member' do
      expect(execute_service[:status]).to eq(:error)
      expect(execute_service[:message]).to include("#{member.username}: Access level is not included in the list")
      expect(source.users).not_to include member
      expect(Namespaces::OnboardingUserAddedWorker.jobs.size).to eq(0)
    end
  end

  context 'when passing an existing invite user id' do
    let(:user_ids) { create(:project_member, :invited, project: source).invite_email }

    it 'does not add a member' do
      expect(execute_service[:status]).to eq(:error)
      expect(execute_service[:message]).to eq('Invite email has already been taken')
      expect(Namespaces::OnboardingUserAddedWorker.jobs.size).to eq(0)
    end
  end
end
