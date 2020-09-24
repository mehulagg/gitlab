# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Issues::MoveService do
  let(:user) { create(:user) }
  let(:old_project) { create(:project) }
  let(:new_project) { create(:project, group: create(:group)) }
  let(:old_issue) { create(:issue, project: old_project, author: user) }
  let(:move_service) { described_class.new(old_project, user) }

  before do
    old_project.add_reporter(user)
    new_project.add_reporter(user)
  end

  describe '#execute' do
    context 'group issue hooks' do
      let!(:hook) { create(:group_hook, group: new_project.group, issues_events: true) }

      it 'executes group issue hooks' do
        allow_next_instance_of(WebHookService) do |instance|
          allow(instance).to receive(:execute)
        end

        # Ideally, we'd test that `WebHookWorker.jobs.size` increased by 1,
        # but since the entire spec run takes place in a transaction, we never
        # actually get to the `after_commit` hook that queues these jobs.
        expect { move_service.execute(old_issue, new_project) }
          .not_to raise_error # Sidekiq::Worker::EnqueueFromTransactionError
      end
    end

    context 'resource weight events' do
      let(:old_issue) { create(:issue, project: old_project, author: user, weight: 5) }
      let!(:event1) { create(:resource_weight_event, issue: old_issue, weight: 1) }
      let!(:event2) { create(:resource_weight_event, issue: old_issue, weight: 42) }
      let!(:event3) { create(:resource_weight_event, issue: old_issue, weight: 5) }

      let!(:another_old_issue) { create(:issue, project: new_project, author: user) }
      let!(:event4) { create(:resource_weight_event, issue: another_old_issue, weight: 2) }

      it 'creates expected resource weight events' do
        new_issue = move_service.execute(old_issue, new_project)

        expect(new_issue.resource_weight_events.map(&:weight)).to contain_exactly(1, 42, 5)
      end
    end
  end

  describe '#rewrite_related_vulnerability_issues' do
    let(:user) { create(:user) }

    let!(:vulnerabilities_issue_link) { create(:vulnerabilities_issue_link, issue: old_issue) }

    it 'updates all vulnerability issue links with new issue' do
      new_issue = move_service.execute(old_issue, new_project)

      expect(vulnerabilities_issue_link.reload.issue).to eq(new_issue)
    end
  end

  describe '#rewrite_epic_issue' do
    context 'issue assigned to epic' do
      let!(:epic_issue) { create(:epic_issue, issue: old_issue) }

      before do
        stub_licensed_features(epics: true)
      end

      it 'updates epic issue reference' do
        epic_issue.epic.group.add_reporter(user)

        new_issue = move_service.execute(old_issue, new_project)

        expect(new_issue.epic_issue).to eq(epic_issue)
      end

      it 'ignores epic issue reference if user can not update the epic' do
        new_issue = move_service.execute(old_issue, new_project)

        expect(new_issue.epic_issue).to be_nil
      end
    end
  end
end
