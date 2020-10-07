# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Issues::ReopenService do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:issue) { create(:issue, :closed, project: project) }
  let_it_be(:blocked_issue) { create(:issue, project: project) }

  subject { described_class.new(project, user).execute(issue) }

  before do
    create(:issue_link, source: issue, target: blocked_issue, link_type: ::IssueLink::TYPE_BLOCKS)
    issue.update!(blocking_issues_count: 0)
  end

  describe '#execute' do
    context 'when user is not authorized to reopen issue' do
      before do
        project.add_guest(user)
      end

      it 'does not update blocking issues count' do
        expect { subject }.not_to change { issue.blocking_issues_count }.from(0)
      end
    end

    context 'when user is authorized to reopen issue' do
      before do
        project.add_maintainer(user)
      end

      it 'updates blocking issues count' do
        expect { subject }.to change { issue.blocking_issues_count }.from(0).to(1)
      end
    end
  end
end
