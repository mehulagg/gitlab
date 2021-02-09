# frozen_string_literal: true

require 'rake_helper'

RSpec.describe 'gitlab:pages' do
  before(:context) do
    Rake.application.rake_require 'tasks/gitlab/pages'
  end

  describe 'migrate_legacy_storage task' do
    subject { run_rake_task('gitlab:pages:migrate_legacy_storage') }

    it 'calls migration service' do
      expect_next_instance_of(::Pages::MigrateFromLegacyStorageService, anything, 3, 10) do |service|
        expect(service).to receive(:execute).and_call_original
      end

      subject
    end

    it 'uses PAGES_MIGRATION_THREADS environment variable' do
      stub_env('PAGES_MIGRATION_THREADS', '5')

      expect_next_instance_of(::Pages::MigrateFromLegacyStorageService, anything, 5, 10) do |service|
        expect(service).to receive(:execute).and_call_original
      end

      subject
    end

    it 'uses PAGES_MIGRATION_BATCH_SIZE environment variable' do
      stub_env('PAGES_MIGRATION_BATCH_SIZE', '100')

      expect_next_instance_of(::Pages::MigrateFromLegacyStorageService, anything, 3, 100) do |service|
        expect(service).to receive(:execute).and_call_original
      end

      subject
    end
  end

  describe 'clean_migrated_zip_storage task' do
    it 'removes only migrated deployments' do
      migrated_project = create(:project)
      FileUtils.mkdir_p File.join(migrated_project.pages_path, "public")
      File.open(File.join(migrated_project.pages_path, "public/index.html"), "w") do |f|
        f.write("Hello!")
      end
      migrated_project.mark_pages_as_deployed
      run_rake_task('gitlab:pages:migrate_legacy_storage')
      migrated_deployment = migrated_project.reload.pages_metadatum.pages_deployment

      another_project = create(:project)
      not_migrated_deployment = create(:pages_deployment, project: another_project)

      expect(PagesDeployment.all).to contain_exactly(migrated_deployment, not_migrated_deployment)

      run_rake_task('gitlab:pages:clean_migrated_zip_storage')

      expect(PagesDeployment.all).to contain_exactly(not_migrated_deployment)
    end
  end
end
