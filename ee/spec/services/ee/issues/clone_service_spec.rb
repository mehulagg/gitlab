# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Issues::CloneService do
  let_it_be(:user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:old_project) { create(:project, group: group) }
  let_it_be(:new_project) { create(:project, group: group) }
  let_it_be(:old_issue, reload: true) { create(:issue, project: old_project, author: user) }

  let(:clone_service) { described_class.new(old_project, user) }

  before do
    group.add_reporter(user)
  end

  describe '#execute' do
    context 'group issue hooks' do
      let!(:hook) { create(:group_hook, group: group, issues_events: true) }

      it 'executes group issue hooks' do
        allow_next_instance_of(WebHookService) do |instance|
          allow(instance).to receive(:execute)
        end

        # Ideally, we'd test that `WebHookWorker.jobs.size` increased by 1,
        # but since the entire spec run takes place in a transaction, we never
        # actually get to the `after_commit` hook that queues these jobs.
        expect { clone_service.execute(old_issue, new_project) }
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
        new_issue = clone_service.execute(old_issue, new_project)

        expect(new_issue.resource_weight_events.map(&:weight)).to contain_exactly(1, 42, 5)
      end
    end
  end

  describe '#add_epic' do
    context 'issue assigned to epic' do
      let_it_be(:epic) { create(:epic, group: group) }

      before do
        stub_licensed_features(epics: true)
        create(:epic_issue, issue: old_issue, epic: epic)
      end

      it 'creates epic reference' do
        new_issue = clone_service.execute(old_issue, new_project)

        expect(new_issue.epic).to eq(epic)
      end

      it 'tracks usage data for changed epic action' do
        expect(Gitlab::UsageDataCounters::IssueActivityUniqueCounter).to receive(:track_issue_changed_epic_action).with(author: user)

        clone_service.execute(old_issue, new_project)
      end

      context 'user can not update the epic' do
        before do
          group.group_member(user).destroy
          old_project.add_reporter(user)
          new_project.add_reporter(user)
        end

        it 'ignores epic reference' do
          new_issue = clone_service.execute(old_issue, new_project)

          expect(new_issue.epic).to be_nil
        end

        it 'does not send usage data for changed epic action' do
          expect(Gitlab::UsageDataCounters::IssueActivityUniqueCounter).not_to receive(:track_issue_changed_epic_action)

          clone_service.execute(old_issue, new_project)
        end
      end

      context 'epic update fails' do
        it 'does not send usage data for changed epic action' do
          allow_next_instance_of(::Issues::UpdateService) do |update_service|
            allow(update_service).to receive(:execute).and_return(false)
          end

          expect(Gitlab::UsageDataCounters::IssueActivityUniqueCounter).not_to receive(:track_issue_changed_epic_action)

          clone_service.execute(old_issue, new_project)
        end
      end
    end
  end
end
