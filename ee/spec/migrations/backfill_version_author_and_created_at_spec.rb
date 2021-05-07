# frozen_string_literal: true
require 'spec_helper'
require_migration!

RSpec.describe BackfillVersionAuthorAndCreatedAt do
  let_it_be(:migration_name) { described_class::MIGRATION.to_s.demodulize }
  let_it_be(:projects) { table(:projects) }
  let_it_be(:issues) { table(:issues) }
  let_it_be(:versions) { table(:design_management_versions) }
  let_it_be(:users) { table(:users) }

  let(:project) { projects.create!(name: 'gitlab', path: 'gitlab-org/gitlab-ce', namespace_id: 1) }
  let(:issue_1) { create_issue }
  let(:issue_2) { create_issue }
  let(:issue_3) { create_issue }
  let(:author) { users.create!(email: 'email@email.com', name: 'foo', username: 'foo', projects_limit: 0) }

  def create_issue
    issues.create!(project_id: project.id)
  end

  def create_version(attrs = {})
    unless attrs[:issue_id]
      issue = create_issue
      attrs[:issue_id] = issue.id
    end

    versions.create!(attrs)
  end

  describe 'scheduling' do
    it 'schedules background migrations in bulk, one job per unique issue id' do
      create_version(sha: 'foo', issue_id: issue_1.id)
      create_version(sha: 'bar', issue_id: issue_1.id)
      create_version(sha: 'baz', issue_id: issue_2.id)

      Sidekiq::Testing.fake! do
        expect(BackgroundMigrationWorker).to receive(:bulk_perform_async).with(
          [[migration_name, [issue_1.id]], [migration_name, [issue_2.id]]]
        )

        migrate!
      end
    end

    it 'schedules background migrations in batches' do
      create_version(sha: 'foo', issue_id: issue_1.id)
      create_version(sha: 'bar', issue_id: issue_2.id)
      create_version(sha: 'baz', issue_id: issue_3.id)

      stub_const("#{described_class.name}::BATCH_SIZE", 2)

      Sidekiq::Testing.fake! do
        # First batch
        expect(BackgroundMigrationWorker).to receive(:bulk_perform_async).with(
          [[migration_name, [issue_1.id]], [migration_name, [issue_2.id]]]
        )
        # Second batch
        expect(BackgroundMigrationWorker).to receive(:bulk_perform_async).with(
          [[migration_name, [issue_3.id]]]
        )

        migrate!
      end
    end
  end

  describe 'scoping version records' do
    it 'schedules background migrations for versions that have NULL author_ids' do
      version = create_version(sha: 'foo', created_at: Time.now)

      expect(version.author_id).to be_nil

      Sidekiq::Testing.fake! do
        expect(BackgroundMigrationWorker).to receive(:bulk_perform_async).with(
          [[migration_name, [version.issue_id]]]
        )

        migrate!
      end
    end

    it 'schedules background migrations for versions that have NULL created_ats' do
      version = create_version(sha: 'foo', author_id: author.id)
      # We can't create a record with NULL created_at within this migration
      # so update it here to be NULL.
      version.update!(created_at: nil)

      expect(version.created_at).to be_nil

      Sidekiq::Testing.fake! do
        expect(BackgroundMigrationWorker).to receive(:bulk_perform_async).with(
          [[migration_name, [version.issue_id]]]
        )

        migrate!
      end
    end

    it 'does not schedule background migrations for versions that have author_ids and created_ats' do
      create_version(sha: 'foo', author_id: author.id, created_at: Time.now)

      Sidekiq::Testing.fake! do
        expect(BackgroundMigrationWorker).not_to receive(:bulk_perform_async)

        migrate!
      end
    end

    it 'does not schedule background migrations for versions that are in projects that are pending deletion' do
      project.update!(pending_delete: true)
      create_version(sha: 'foo')

      Sidekiq::Testing.fake! do
        expect(BackgroundMigrationWorker).not_to receive(:bulk_perform_async)

        migrate!
      end
    end
  end
end
