# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JiraConnect::SyncBranchWorker do
  describe '#perform' do
    let_it_be(:project) { create(:project, :repository) }
    let(:project_id) { project.id }
    let(:branch_name) { 'master' }
    let(:commit_shas) { %w(b83d6e3 5a62481) }
    let(:jira_connect_sync_service) { JiraConnect::SyncService.new(project) }

    before do
      stub_request(:post, 'https://sample.atlassian.net/rest/devinfo/0.10/bulk').to_return(status: 200, body: '', headers: {})

      jira_connect_sync_service
      allow(JiraConnect::SyncService).to receive(:new) { jira_connect_sync_service }
    end

    it_behaves_like 'an idempotent worker' do
      let(:job_args) { [project_id, branch_name, commit_shas] }

      it 'calls JiraConnect::SyncService#execute' do
        expect(jira_connect_sync_service).to receive(:execute)
          .exactly(IdempotentWorkerHelper::WORKER_EXEC_TIMES).times
          .with(branches: [instance_of(Gitlab::Git::Branch)], commits: project.commits_by(oids: commit_shas))

        subject
      end

      context 'without branch name' do
        let(:branch_name) { nil }

        it 'calls JiraConnect::SyncService#execute' do
          expect(jira_connect_sync_service).to receive(:execute)
            .exactly(IdempotentWorkerHelper::WORKER_EXEC_TIMES).times
            .with(branches: nil, commits: project.commits_by(oids: commit_shas))

          subject
        end
      end

      context 'without commits' do
        let(:commit_shas) { nil }

        it 'calls JiraConnect::SyncService#execute' do
          expect(jira_connect_sync_service).to receive(:execute)
            .exactly(IdempotentWorkerHelper::WORKER_EXEC_TIMES).times
            .with(branches: [instance_of(Gitlab::Git::Branch)], commits: nil)

          subject
        end
      end

      context 'when project no longer exists' do
        let(:project_id) { non_existing_record_id }

        it 'does not call JiraConnect::SyncService' do
          expect(JiraConnect::SyncService).not_to receive(:new)

          subject
        end
      end
    end
  end
end
