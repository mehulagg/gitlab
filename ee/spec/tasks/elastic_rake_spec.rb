# frozen_string_literal: true

require 'rake_helper'

RSpec.describe 'elastic rake tasks', :elastic do
  before do
    Rake.application.rake_require 'tasks/gitlab/elastic'
  end

  describe 'create_empty_index' do
    subject { run_rake_task('gitlab:elastic:create_empty_index') }

    before do
      es_helper.delete_index
    end

    it 'creates an index' do
      expect { subject }.to change { es_helper.index_exists? }.from(false).to(true)
    end

    it 'marks all migrations as completed' do
      expect(Elastic::DataMigrationService).to receive(:mark_all_as_completed!).and_call_original
      expect(Elastic::MigrationRecord.persisted_versions(completed: true)).to eq([])

      subject
      refresh_index!

      migrations = Elastic::DataMigrationService.migrations.map(&:version)
      expect(Elastic::MigrationRecord.persisted_versions(completed: true)).to eq(migrations)
    end
  end

  describe 'delete_index' do
    subject { run_rake_task('gitlab:elastic:delete_index') }

    it 'removes the index' do
      expect { subject }.to change { es_helper.index_exists? }.from(true).to(false)
    end
  end
end
