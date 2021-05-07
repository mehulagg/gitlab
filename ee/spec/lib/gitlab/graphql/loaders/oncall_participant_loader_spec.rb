# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Graphql::Loaders::OncallParticipantLoader do
  describe '#find' do
    let_it_be(:participant1) { create(:incident_management_oncall_participant) }
    let_it_be(:participant2) { create(:incident_management_oncall_participant) }
    let_it_be(:participant3) { create(:incident_management_oncall_participant) }

    it 'finds a participant by id' do
      first_result = described_class.new(participant1.id).find
      second_result = described_class.new(participant2.id).find

      expect(first_result.sync).to eq(participant1)
      expect(second_result.sync).to eq(participant2)
    end

    it 'includes the user association' do
      expect do
        [described_class.new(participant3.id).find,
         described_class.new(participant2.id).find,
         described_class.new(participant1.id).find].map(&:sync).map(&:user)
      end.not_to exceed_query_limit(2)
    end
  end
end
