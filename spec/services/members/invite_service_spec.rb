# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Members::InviteService do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:project_user) { create(:user) }

  before do
    project.add_maintainer(user)
  end

  it 'adds an existing user to members' do
    params = { email: project_user.email.to_s, access_level: Gitlab::Access::GUEST }
    result = described_class.new(user, params).execute(project)

    expect(result[:status]).to eq(:success)
    expect(project.users).to include project_user
  end

  it 'creates a new user for an unknown email address' do
    params = { email: 'email@example.org', access_level: Gitlab::Access::GUEST }
    result = described_class.new(user, params).execute(project)

    expect(result[:status]).to eq(:success)
  end

  it 'limits the number of emails to 100' do
    emails = 1.upto(101).to_a.join('@example.org,')
    params = { email: emails, access_level: Gitlab::Access::GUEST }

    result = described_class.new(user, params).execute(project)

    expect(result[:status]).to eq(:error)
    expect(result[:message]).to be_present
  end

  it 'does not invite an invalid email' do
    params = { email: project_user.id.to_s, access_level: Gitlab::Access::GUEST }
    result = described_class.new(user, params).execute(project)

    expect(result[:status]).to eq(:error)
    expect(result[:message]).to include("Invite email is invalid")
    expect(project.users).not_to include project_user
  end

  it 'does not invite to an invalid access level' do
    params = { email: 'test@example.com', access_level: -1 }
    result = described_class.new(user, params).execute(project)

    expect(result[:status]).to eq(:error)
    expect(result[:message]).to include("Access level is not included in the list")
  end

  it 'does not add a member with an existing invite' do
    invited_member = create(:project_member, :invited, project: project)

    params = { email: invited_member.invite_email,
               access_level: Gitlab::Access::GUEST }
    result = described_class.new(user, params).execute(project)

    expect(result[:status]).to eq(:error)
    expect(result[:message]).to eq('Member already invited')
  end
end
