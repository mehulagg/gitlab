# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssuePolicy do
  let(:owner) { build_stubbed(:user) }
  let(:namespace) { build_stubbed(:namespace, owner: owner) }
  let(:project) { build_stubbed(:project, namespace: namespace) }
  let(:issue) { build_stubbed(:issue, project: project) }

  subject { described_class.new(owner, issue) }

  before do
    allow(issue).to receive(:namespace).and_return namespace
    allow(project).to receive(:design_management_enabled?).and_return true
  end

  context 'when namespace is locked because storage usage limit exceeded' do
    before do
      allow(namespace).to receive(:over_storage_limit?).and_return true
    end

    it { is_expected.to be_disallowed(:create_issue, :update_issue, :read_issue_iid, :reopen_issue, :create_design, :create_note) }
  end

  context 'when namespace is not locked because storage usage limit not exceeded' do
    before do
      allow(namespace).to receive(:over_storage_limit?).and_return false
    end

    it { is_expected.to be_allowed(:create_issue, :update_issue, :read_issue_iid, :reopen_issue, :create_design, :create_note) }
  end

  context 'promote_to_epic rule' do
    let(:guest) { create(:user) }
    let(:author) { create(:user) }
    let(:assignee) { create(:user) }
    let(:reporter) { create(:user) }
    let(:developer) { create(:user) }
    let(:group) { create(:group, :public) }

    let(:project) { create(:project, group: group) }
    let(:issue) { create(:issue, project: project) }

    before do
      project.add_guest(guest)
      project.add_guest(author)
      project.add_guest(assignee)
      project.add_reporter(reporter)
    end

    it { expect(permissions(guest, issue)).to be_disallowed(:promote_to_epic) }
    it { expect(permissions(author, issue)).to be_disallowed(:promote_to_epic) }
    it { expect(permissions(assignee, issue)).to be_disallowed(:promote_to_epic) }
    it { expect(permissions(reporter, issue)).to be_allowed(:promote_to_epic) }
  end

  def permissions(user, issue)
    described_class.new(user, issue)
  end
end
