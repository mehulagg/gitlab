# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::ResourceEvents::SyntheticWeightNotesBuilderService do
  describe '#execute' do
    let!(:user) { create(:user) }

    let!(:issue) { create(:issue, author: user) }

    let!(:event1) { create(:resource_weight_event, issue: issue) }
    let!(:event2) { create(:resource_weight_event, issue: issue) }
    let!(:event3) { create(:resource_weight_event, issue: issue) }

    it 'returns the expected synthetic notes' do
      notes = EE::ResourceEvents::SyntheticWeightNotesBuilderService.new(issue, user).execute

      expect(notes.size).to eq(3)
    end
  end
end
