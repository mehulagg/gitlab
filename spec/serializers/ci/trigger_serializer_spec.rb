# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::TriggerSerializer do
  describe '#represent' do
    subject { described_class.new.represent(trigger) }

    let(:trigger) { build(:ci_trigger) }

    it 'matches schema' do
      expect(subject.to_json).to match_schema('entities/trigger')
    end
  end
end
