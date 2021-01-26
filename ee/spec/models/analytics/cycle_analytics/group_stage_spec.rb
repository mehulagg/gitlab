# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::CycleAnalytics::GroupStage do
  describe 'uniqueness validation on name' do
    subject { build(:cycle_analytics_group_stage) }

    it { is_expected.to validate_uniqueness_of(:name).scoped_to([:group_id, :group_value_stream_id]) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:value_stream) }
  end

  it_behaves_like 'value stream analytics stage' do
    let(:parent) { create(:group) }
    let(:parent_name) { :group }
  end

  include_examples 'value stream analytics label based stage' do
    let_it_be(:parent) { create(:group) }
    let_it_be(:parent_in_subgroup) { create(:group, parent: parent) }
    let_it_be(:group_label) { create(:group_label, group: parent) }
    let_it_be(:parent_outside_of_group_label_scope) { create(:group) }
  end

  context 'relative positioning' do
    it_behaves_like 'a class that supports relative positioning' do
      let(:parent) { create(:group) }
      let(:factory) { :cycle_analytics_group_stage }
      let(:default_params) { { group: parent } }
    end
  end

  context 'when the event identifier is using the old, recently deduplicated identifier' do
    let(:group) { create(:group) }
    let(:value_stream) { create(:cycle_analytics_group_value_stream, group: group) }
    let(:invalid_identifier) { 6 }

    let(:stage_params) do
      {
        name: 'My Stage',
        parent: group,
        start_event_identifier: :merge_request_created,
        end_event_identifier: :merge_request_merged,
        value_stream: value_stream
      }
    end

    let(:stage) { described_class.create!(stage_params) }

    before do
      # update the columns directly so validations are skipped
      stage.update_column(:start_event_identifier, invalid_identifier)
      stage.update_column(:end_event_identifier, invalid_identifier)
    end

    subject { described_class.find(stage.id) }

    it 'loads the correct start event' do
      expect(subject.start_event).to be_a_kind_of(Gitlab::Analytics::CycleAnalytics::StageEvents::IssueFirstMentionedInCommit)
    end

    it 'loads the correct end event' do
      expect(subject.end_event).to be_a_kind_of(Gitlab::Analytics::CycleAnalytics::StageEvents::IssueFirstMentionedInCommit)
    end
  end
end
