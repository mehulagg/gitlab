# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe SchedulePopulateResolvedOnDefaultBranchColumn do
  before do
    allow_any_instance_of(Gitlab).to receive(:ee?).and_return(ee?)
  end

  around do |example|
    freeze_time { Sidekiq::Testing.fake! { example.run } }
  end

  context 'when the Gitlab instance is CE' do
    let(:ee?) { false }

    it 'does not run the migration' do
      expect { migrate! }.not_to change { BackgroundMigrationWorker.jobs.size }
    end
  end

  context 'when the Gitlab instance is EE' do
    let(:ee?) { true }
    let(:namespaces) { table(:namespaces) }
    let(:projects) { table(:projects) }
    let(:vulnerabilities) { table(:vulnerabilities) }
    let(:users) { table(:users) }
    let(:namespace) { namespaces.create!(name: "foo", path: "bar") }
    let!(:project_1) { projects.create!(namespace_id: namespace.id) }
    let!(:project_2) { projects.create!(namespace_id: namespace.id) }
    let!(:project_3) { projects.create!(namespace_id: namespace.id) }
    let(:user) { users.create!(name: 'John Doe', email: 'test@example.com', projects_limit: 1) }
    let(:vulnerability_data) do
      {
        author_id: user.id,
        title: 'Vulnerability',
        severity: 5,
        confidence: 5,
        report_type: 5
      }
    end

    before do
      vulnerabilities.create!(**vulnerability_data, project_id: project_1.id)
      vulnerabilities.create!(**vulnerability_data, project_id: project_2.id)

      stub_const("#{described_class.name}::BATCH_SIZE", 1)
    end

    it 'schedules the background jobs', :aggregate_failures do
      migrate!

      expect(BackgroundMigrationWorker.jobs.size).to be(2)
      expect(described_class::MIGRATION_CLASS).to be_scheduled_delayed_migration(5.minutes, project_1.id)
      expect(described_class::MIGRATION_CLASS).to be_scheduled_delayed_migration(10.minutes, project_2.id)
    end
  end
end
