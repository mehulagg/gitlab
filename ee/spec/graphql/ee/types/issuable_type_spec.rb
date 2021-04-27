# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['Issuable'] do
  it 'returns possible types' do
    expect(described_class.possible_types).to include(Types::EpicType)
  end

  describe '.resolve_type' do
    it 'resolves epics' do
      expect(described_class.resolve_type(build(:epic), {})).to eq(Types::EpicType)
    end
  end
end
