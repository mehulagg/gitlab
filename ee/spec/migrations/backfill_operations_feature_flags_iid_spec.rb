# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe BackfillOperationsFeatureFlagsIid do
  let(:namespaces)     { table(:namespaces) }
  let(:projects)       { table(:projects) }
  let(:flags)          { table(:operations_feature_flags) }
  let(:issues)         { table(:issues) }
  let(:merge_requests) { table(:merge_requests) }
  let(:internal_ids)   { table(:internal_ids) }

  def setup
    namespace = namespaces.create!(name: 'foo', path: 'foo')
    projects.create!(namespace_id: namespace.id)
  end

  it 'backfills the iid for a flag' do
    project = setup
    flag = flags.create!(project_id: project.id, active: true, name: 'test_flag')

    expect(flag.iid).to be_nil

    disable_migrations_output { migrate! }

    expect(flag.reload.iid).to eq(1)
  end

  it 'backfills the iid for multiple flags' do
    project = setup
    flag_a = flags.create!(project_id: project.id, active: true, name: 'test_flag')
    flag_b = flags.create!(project_id: project.id, active: false, name: 'other_flag')
    flag_c = flags.create!(project_id: project.id, active: false, name: 'last_flag', created_at: '2019-10-11T08:00:11Z')

    expect(flag_a.iid).to be_nil
    expect(flag_b.iid).to be_nil

    disable_migrations_output { migrate! }

    expect(flag_a.reload.iid).to eq(1)
    expect(flag_b.reload.iid).to eq(2)
    expect(flag_c.reload.iid).to eq(3)
  end

  it 'backfills the iid for multiple flags across projects' do
    project_a = setup
    project_b = setup
    flag_a = flags.create!(project_id: project_a.id, active: true, name: 'test_flag')
    flag_b = flags.create!(project_id: project_b.id, active: false, name: 'other_flag')

    expect(flag_a.iid).to be_nil
    expect(flag_b.iid).to be_nil

    disable_migrations_output { migrate! }

    expect(flag_a.reload.iid).to eq(1)
    expect(flag_b.reload.iid).to eq(1)
  end

  it 'does not change an iid for an issue' do
    project = setup
    flag = flags.create!(project_id: project.id, active: true, name: 'test_flag')
    issue = issues.create!(project_id: project.id, iid: 8)
    internal_id = internal_ids.create!(project_id: project.id, usage: 0, last_value: issue.iid)

    disable_migrations_output { migrate! }

    expect(flag.reload.iid).to eq(1)
    expect(issue.reload.iid).to eq(8)
    expect(internal_id.reload.usage).to eq(0)
    expect(internal_id.last_value).to eq(8)
  end

  it 'does not change an iid for a merge request' do
    project_a = setup
    project_b = setup
    flag = flags.create!(project_id: project_a.id, active: true, name: 'test_flag')
    merge_request_a = merge_requests.create!(target_project_id: project_b.id, target_branch: project.default_branch, source_branch: 'feature-1', title: 'merge request', iid: 1)
    merge_request_b = merge_requests.create!(target_project_id: project_b.id, target_branch: project.default_branch, source_branch: 'feature-2', title: 'merge request', iid: 2)
    internal_id = internal_ids.create!(project_id: project_b.id, usage: 1, last_value: merge_request_b.iid)

    disable_migrations_output { migrate! }

    expect(flag.reload.iid).to eq(1)
    expect(merge_request_a.reload.iid).to eq(1)
    expect(merge_request_b.reload.iid).to eq(2)
    expect(internal_id.reload.usage).to eq(1)
    expect(internal_id.last_value).to eq(2)
  end
end
