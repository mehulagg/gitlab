# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Issues::ReopenService do
  let(:project) { create(:project) }
  let(:user) { create(:user) }
  let(:issue) { create(:issue, :closed, project: project) }
  let(:blocked_issue) { create(:issue, project: project) }

  before do
    create(:issue_link, source: issue, target: blocked_issue, link_type: ::IssueLink::TYPE_BLOCKS)
    issue.update!(blocking_issues_count: 0)
  end

  describe '#after_reopen' do
    context 'when user is not authorized to reopen issue' do
      before do
        project.add_guest(user)
      end

      it 'does not update blocking issues count' do
        described_class.new(project, user).execute(issue)

        expect(issue.blocking_issues_count).to eq(0)
      end
    end

    context 'when user is authorized to reopen issue' do
      before do
        project.add_maintainer(user)
      end

      it 'updates blocking issues count' do
        described_class.new(project, user).execute(issue)

        expect(issue.blocking_issues_count).to eq(1)
      end
    end
  end
end
