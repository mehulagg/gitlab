# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::CycleAnalytics::ProjectStage do
  include_examples 'cycle analytics label based stage' do
    let_it_be(:group) { create(:group) }
    let_it_be(:parent) { create(:project, group: group) }
    let_it_be(:parent_in_subgroup) { create(:project, group: create(:group, parent: group)) }
    let_it_be(:group_label) { create(:group_label, group: group) }
    let_it_be(:parent_outside_of_group_label_scope) { create(:project, group: create(:group)) }
  end

  context 'project without group' do
    it 'returns validation error when end event is label based' do
      stage = described_class.new({
        name: 'My Stage',
        parent: create(:project),
        start_event_identifier: :issue_closed,
        end_event_identifier: :issue_label_added,
        end_event_label: create(:group_label)
      })

      expect(stage).to be_invalid
      expect(stage.errors[:project]).to include(s_('CycleAnalyticsStage|should be under a group'))
    end

    it 'returns validation error when start event is label based' do
      stage = described_class.new({
        name: 'My Stage',
        parent: create(:project),
        start_event_identifier: :issue_label_added,
        start_event_label: create(:group_label),
        end_event_identifier: :issue_closed
      })

      expect(stage).to be_invalid
      expect(stage.errors[:project]).to include(s_('CycleAnalyticsStage|should be under a group'))
    end
  end
end
