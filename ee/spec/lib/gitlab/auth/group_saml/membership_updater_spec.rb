# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Auth::GroupSaml::MembershipUpdater do
  let(:user) { create(:user) }
  let(:saml_provider) { create(:saml_provider, default_membership_role: Gitlab::Access::DEVELOPER) }
  let(:group) { saml_provider.group }

  subject { described_class.new(user, saml_provider).execute }

  it 'adds the user to the group' do
    subject

    expect(group.users).to include(user)
  end

  it 'adds the member with the specified `default_membership_role`' do
    subject

    created_member = group.members.find_by(user: user)
    expect(created_member.access_level).to eq(Gitlab::Access::DEVELOPER)
  end

  it "doesn't duplicate group membership" do
    group.add_guest(user)

    subject

    expect(group.members.count).to eq 1
  end

  it "doesn't overwrite existing membership level" do
    group.add_maintainer(user)

    subject

    expect(group.members.pluck(:access_level)).to eq([Gitlab::Access::MAINTAINER])
  end

  it "logs an audit event" do
    expect do
      subject
    end.to change { AuditEvent.by_entity('Group', group).count }.by(1)

    expect(AuditEvent.last.details).to include(add: 'user_access', target_details: user.name, as: 'Developer')
  end
end
