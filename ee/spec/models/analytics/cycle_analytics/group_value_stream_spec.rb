# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::CycleAnalytics::GroupValueStream, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to have_many(:stages) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }

    it 'validates uniqueness of name' do
      group = create(:group)
      create(:cycle_analytics_group_value_stream, name: 'test', group: group)

      value_stream = build(:cycle_analytics_group_value_stream, name: 'test', group: group)

      expect(value_stream).to be_invalid
      expect(value_stream.errors.messages).to eq(name: [I18n.t('errors.messages.taken')])
    end
  end

  describe 'ordering of stages' do
    let(:group) { create(:group) }
    let(:value_stream) do
      create(:cycle_analytics_group_value_stream, group: group, stages: [
        create(:cycle_analytics_group_stage, group: group, name: "stage 1", relative_position: 5),
        create(:cycle_analytics_group_stage, group: group, name: "stage 2", relative_position: nil),
        create(:cycle_analytics_group_stage, group: group, name: "stage 3", relative_position: 1)
      ])
    end

    before do
      value_stream.reload
    end

    describe 'stages attribute' do
      it 'sorts stages by relative position' do
        names = value_stream.stages.map(&:name)
        expect(names).to eq(['stage 3', 'stage 1', 'stage 2'])
      end
    end
  end
end
