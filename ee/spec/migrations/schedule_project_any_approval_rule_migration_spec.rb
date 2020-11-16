# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe ScheduleProjectAnyApprovalRuleMigration do
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:namespace) { namespaces.create(name: 'gitlab', path: 'gitlab-org') }

  def create_project(id, options = {})
    default_options = {
      id: id,
      namespace_id: namespace.id,
      name: 'foo',
      approvals_before_merge: 2
    }

    projects.create(default_options.merge(options))
  end

  it 'correctly schedules background migrations' do
    create_project(1, approvals_before_merge: 0)
    create_project(2)
    create_project(3, approvals_before_merge: 0)
    create_project(4)
    create_project(5, approvals_before_merge: 0)
    create_project(6)

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
      create_project(2)

      Sidekiq::Testing.fake! do
        freeze_time do
          migrate!

          expect(BackgroundMigrationWorker.jobs.size).to eq(0)
        end
      end
    end
  end
end
