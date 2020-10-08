# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Members::UpdateService do
  let(:project) { create(:project, :public) }
  let(:group) { create(:group, :public) }
  let(:current_user) { create(:user) }
  let(:member_user) { create(:user) }
  let(:permission) { :update }
  let(:member) { source.members_and_requesters.find_by!(user_id: member_user.id) }
  let(:params) do
    { access_level: Gitlab::Access::MAINTAINER, expires_at: 2.days.from_now }
  end

  before do
    project.add_developer(member_user)
    group.add_developer(member_user)
  end

  shared_examples_for 'logs an audit event' do
    specify do
      expect do
        described_class.new(current_user, params).execute(member, permission: permission)
      end.to change { AuditEvent.count }.by(1)
    end
  end

  context 'when current user can update the given member' do
    before do
      project.add_maintainer(current_user)
      group.add_owner(current_user)
    end

    it_behaves_like 'logs an audit event' do
      let(:source) { project }
    end

    it_behaves_like 'logs an audit event' do
      let(:source) { group }
    end
  end
end
