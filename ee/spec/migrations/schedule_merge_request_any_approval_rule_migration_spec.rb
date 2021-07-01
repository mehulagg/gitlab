# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe ScheduleMergeRequestAnyApprovalRuleMigration do
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:namespace) { namespaces.create!(name: 'gitlab', path: 'gitlab-org') }
  let(:project) { projects.create!(namespace_id: namespace.id, name: 'foo') }
  let(:merge_requests) { table(:merge_requests) }

  def create_merge_request(id, options = {})
    default_options = {
      id: id,
      target_project_id: project.id,
      target_branch: project.default_branch,
      source_project_id: project.id,
      source_branch: 'mr name',
      title: "mr name#{id}",
      approvals_before_merge: 2
    }

    merge_requests.create!(default_options.merge(options))
  end

  it 'correctly schedules background migrations' do
    create_merge_request(1, approvals_before_merge: nil)
    create_merge_request(2)
    create_merge_request(3, approvals_before_merge: 0)
    create_merge_request(4)
    create_merge_request(5, approvals_before_merge: 0)
    create_merge_request(6)

    stub_const("#{described_class.name}::BATCH_SIZE", 2)

    Sidekiq::Testing.fake! do
      freeze_time do
        migrate!

        expect(described_class::MIGRATION)
          .to be_scheduled_delayed_migration(8.minutes, 2, 4)

        expect(described_class::MIGRATION)
          .to be_scheduled_delayed_migration(16.minutes, 6, 6)

        expect(BackgroundMigrationWorker.jobs.size).to eq(2)
      end
    end
  end

  context 'for FOSS version' do
    before do
      allow(Gitlab).to receive(:ee?).and_return(false)
    end

    it 'does not schedule any jobs' do
      create_merge_request(2)

      Sidekiq::Testing.fake! do
        freeze_time do
          migrate!

          expect(BackgroundMigrationWorker.jobs.size).to eq(0)
        end
      end
    end
  end
end
