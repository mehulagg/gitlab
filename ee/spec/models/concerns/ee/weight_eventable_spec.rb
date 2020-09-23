# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::WeightEventable do
  subject { build(:issue) }

  describe 'associations' do
    it { is_expected.to have_many(:resource_weight_events) }
  end

  describe '#first_weight_event?' do
    it 'returns false as it has no weight changes' do
      allow(subject).to receive(:previous_changes).and_return({ 'weight' => nil })

      expect(subject.first_weight_event?).to be false
    end

    it 'returns false as it has no previous weight' do
      allow(subject).to receive(:previous_changes).and_return({ 'weight' => [nil, 3] })

      expect(subject.first_weight_event?).to be false
    end

    it 'returns false as it has already a resoure_weight_event' do
      create(:resource_weight_event, issue: subject)
      allow(subject).to receive(:previous_changes).and_return({ 'weight' => [nil, 3] })

      expect(subject.first_weight_event?).to be false
    end

    it 'returns true as the previous weight exists and there is no resoure_weight_event record' do
      allow(subject).to receive(:previous_changes).and_return({ 'weight' => [3, 4] })

      expect(subject.first_weight_event?).to be true
    end
  end
end
