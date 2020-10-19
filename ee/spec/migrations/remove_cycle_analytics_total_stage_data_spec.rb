# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe RemoveCycleAnalyticsTotalStageData, :migration do
  let(:group_stages_table) { table(:analytics_cycle_analytics_group_stages) }
  let(:project_stages_table) { table(:analytics_cycle_analytics_project_stages) }
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:group_value_streams_table) { table(:analytics_cycle_analytics_group_value_streams) }

  let(:project) { projects.create!(id: 12058473, namespace_id: group.id, name: 'gitlab', path: 'gitlab') }
  let(:group) { namespaces.create!(name: 'foo', path: 'foo') }
  let(:group_value_stream) { group_value_streams_table.create!(group_id: group.id, name: 'default') }

  before do
    group_stages_table.create!(
      id: 1,
      name: 'production',
      group_value_stream_id: group_value_stream.id,
      group_id: group.id,
      start_event_identifier: 1,
      end_event_identifier: 2
    )

    group_stages_table.create!(
      id: 2,
      name: 'plan',
      group_value_stream_id: group_value_stream.id,
      group_id: group.id,
      start_event_identifier: 1,
      end_event_identifier: 2
    )

    project_stages_table.create!(
      id: 1,
      name: 'production',
      project_id: project.id,
      start_event_identifier: 1,
      end_event_identifier: 2
    )

    project_stages_table.create!(
      id: 2,
      name: 'plan',
      project_id: project.id,
      start_event_identifier: 1,
      end_event_identifier: 2
    )
  end

  it 'removes "production" stage info and keeps other stages' do
    migrate!

    expect(group_stages_table.all.map(&:id)).to eq [2]
    expect(project_stages_table.all.map(&:id)).to eq [2]
  end
end
