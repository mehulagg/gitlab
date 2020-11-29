# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20190926180443_schedule_epic_issues_after_epics_move.rb')

RSpec.describe ScheduleEpicIssuesAfterEpicsMove do
  let(:users) { table(:users) }
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:epics) { table(:epics) }
  let(:issues) { table(:issues) }
  let(:epic_issues) { table(:epic_issues) }

  let(:user) { users.create!(name: 'test', email: 'test@example.com', projects_limit: 5) }
  let(:group) { namespaces.create!(name: 'gitlab', path: 'gitlab-org') }
  let(:project) { projects.create!(namespace_id: group.id, name: 'foo') }
  let(:epic_params) do
    {
      title: 'Epic',
      title_html: 'Epic',
      group_id: group.id,
      author_id: user.id
    }
  end

  let(:issue_params) do
    {
      title: 'Issue',
      title_html: 'Issue',
      project_id: project.id,
      author_id: user.id
    }
  end

  let!(:epic_1) { epics.create!(epic_params.merge(iid: 1, relative_position: 100)) }
  let!(:epic_2) { epics.create!(epic_params.merge(iid: 2, relative_position: 200)) }
  let!(:epic_3) { epics.create!(epic_params.merge(iid: 3, relative_position: 300)) }
  let(:issue)   { issues.create!(issue_params.merge(iid: 1)) }
  let!(:epic_issue) { epic_issues.create!(issue_id: issue.id, epic_id: epic_1.id, relative_position: 1) }

  before do
    stub_const("#{described_class}::BATCH_SIZE", 2)
  end

  it 'schedules background migrations at correct time', :aggregate_failures do
    Sidekiq::Testing.fake! do
      freeze_time do
        migrate!

        expect(described_class::MIGRATION).to(
          be_scheduled_delayed_migration(5.minutes, epic_1.id, epic_2.id)
        )
        expect(described_class::MIGRATION).to(
          be_scheduled_delayed_migration(10.minutes, epic_3.id, epic_3.id)
        )
        expect(BackgroundMigrationWorker.jobs.size).to eq(2)
      end
    end
  end

  it 'processes scheduled background migrations', :sidekiq_inline do
    perform_enqueued_jobs do
      expect(epic_issue.relative_position).to eq(1)

      migrate!

      expect(epic_issue.reload.relative_position).to be > 300
    end
  end
end
