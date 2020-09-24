# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::CycleAnalytics::EventEntity do
  describe '#type' do
    it 'returns `simple` for non-label based events' do
      event = Gitlab::Analytics::CycleAnalytics::StageEvents::IssueCreated

      expect(described_class.new(event).as_json[:type]).to eq('simple')
    end

    it 'returns `label` for label based events' do
      event = Gitlab::Analytics::CycleAnalytics::StageEvents::IssueLabelAdded

      expect(described_class.new(event).as_json[:type]).to eq('label')
    end
  end
end
