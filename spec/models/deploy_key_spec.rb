# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeployKey, :mailer do
  describe "Associations" do
    it { is_expected.to have_many(:deploy_keys_projects) }
    it { is_expected.to have_many(:projects) }
    it { is_expected.to have_many(:protected_branch_push_access_levels) }
  end

  describe 'notification' do
    let(:user) { create(:user) }

    it 'does not send a notification' do
      perform_enqueued_jobs do
        create(:deploy_key, user: user)
      end

      should_not_email(user)
    end
  end

  describe '#user' do
    let(:deploy_key) { create(:deploy_key) }
    let(:user) { create(:user) }

    context 'when user is set' do
      before do
        deploy_key.user = user
      end

      it 'returns the user' do
        expect(deploy_key.user).to be(user)
      end
    end

    context 'when user is not set' do
      it 'returns the ghost user' do
        expect(deploy_key.user).to eq(User.ghost)
      end
    end
  end

  describe '#check_access_for_default_branch' do
    it 'is true' do
      deploy_key = build(:deploy_key)
      project = build(:project)

      expect(deploy_key.check_access_for_default_branch(project)).to be_truthy
    end
  end

  describe '#check_protected_ref_access' do
    let_it_be(:deploy_key) { create(:deploy_key) }
    let(:project) { build(:project) }
    let(:access_level) { create(:protected_branch_push_access_level) }

    subject { deploy_key.check_protected_ref_access(access_level, project) }

    it 'is true when the access level is tied to this deploy key' do
      access_level.deploy_key = deploy_key

      expect(subject).to be_truthy
    end

    it 'is false when it is tied to another deploy key' do
      access_level.deploy_key = create(:deploy_key)

      expect(subject).to be_falsey
    end

    it 'is false when it is not tied to any deploy key' do
      expect(access_level.deploy_key_id).to be_nil
      expect(subject).to be_falsey
    end
  end
end
