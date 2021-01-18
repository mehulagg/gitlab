# frozen_string_literal: true

require 'spec_helper'

require_migration!

RSpec.describe CleanupProjectsWithNullHasExternalIssueTracker, :migration do
  let_it_be(:namespace) { table(:namespaces).create!(name: 'foo', path: 'foo') }
  let(:projects) { table(:projects) }
  let(:services) { table(:services) }
  let(:constraint_name) { 'check_38eb20f8ef' }

  before do
    # In order to insert a row with a NULL to fill.
    ActiveRecord::Base.connection.execute "ALTER TABLE projects DROP CONSTRAINT #{constraint_name}"
  end

  after do
    # Revert DB structure
    ActiveRecord::Base.connection.execute "ALTER TABLE projects ADD CONSTRAINT #{constraint_name} CHECK ((has_external_issue_tracker IS NOT NULL)) NOT VALID;"
  end

  def create_projects!(num)
    Array.new(num) do
      projects.create!(namespace_id: namespace.id)
    end
  end

  def create_active_external_issue_tracker_integrations!(*projects)
    projects.each do |project|
      services.create!(category: 'issue_tracker', project_id: project.id, active: true)
    end
  end

  def create_disabled_external_issue_tracker_integrations!(*projects)
    projects.each do |project|
      services.create!(category: 'issue_tracker', project_id: project.id, active: false)
    end
  end

  def create_active_other_integrations!(*projects)
    projects.each do |project|
      services.create!(category: 'not_issue_tracker', project_id: project.id, active: true)
    end
  end

  it 'sets `projects.has_external_issue_tracker` correctly' do
    project_with_external_issue_tracker_1,
      project_with_external_issue_tracker_2,
      project_with_external_issue_tracker_3,
      project_with_disabled_external_issue_tracker_1,
      project_with_disabled_external_issue_tracker_2,
      project_with_disabled_external_issue_tracker_3,
      project_without_external_issue_tracker_1,
      project_without_external_issue_tracker_2,
      project_without_external_issue_tracker_3 = create_projects!(9)

    create_active_external_issue_tracker_integrations!(
      project_with_external_issue_tracker_1,
      project_with_external_issue_tracker_2,
      project_with_external_issue_tracker_3
    )

    create_disabled_external_issue_tracker_integrations!(
      project_with_disabled_external_issue_tracker_1,
      project_with_disabled_external_issue_tracker_2,
      project_with_disabled_external_issue_tracker_3
    )

    create_active_other_integrations!(
      project_without_external_issue_tracker_1,
      project_without_external_issue_tracker_2,
      project_without_external_issue_tracker_3
    )

    # PG triggers on the services table added in a previous migration
    # will have set the `has_external_issue_tracker` columns to correct data when
    # the services records were created above.
    #
    # We set the `has_external_issue_tracker` columns for projects to NULL or incorrect
    # data manually below to emulate projects in a state before the PG
    # triggers were added.
    project_with_external_issue_tracker_1.update!(has_external_issue_tracker: nil)
    project_with_external_issue_tracker_2.update!(has_external_issue_tracker: false)

    project_with_disabled_external_issue_tracker_1.update!(has_external_issue_tracker: nil)
    project_with_disabled_external_issue_tracker_2.update!(has_external_issue_tracker: true)

    project_without_external_issue_tracker_1.update!(has_external_issue_tracker: nil)
    project_without_external_issue_tracker_2.update!(has_external_issue_tracker: true)

    migrate!

    expected_true = [
      project_with_external_issue_tracker_1,
      project_with_external_issue_tracker_2,
      project_with_external_issue_tracker_3
    ].each(&:reload).map(&:has_external_issue_tracker)

    expected_false = [
      project_without_external_issue_tracker_1,
      project_without_external_issue_tracker_2,
      project_without_external_issue_tracker_3,
      project_with_disabled_external_issue_tracker_1,
      project_with_disabled_external_issue_tracker_2,
      project_with_disabled_external_issue_tracker_3
    ].each(&:reload).map(&:has_external_issue_tracker)

    expect(expected_true).to all(eq(true))
    expect(expected_false).to all(eq(false))
  end
end
