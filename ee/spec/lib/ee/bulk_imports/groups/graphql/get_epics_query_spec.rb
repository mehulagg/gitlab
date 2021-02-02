# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::BulkImports::Groups::Graphql::GetEpicsQuery do
  describe '#variables' do
    let(:entity) { double(source_full_path: 'test', next_page_for: 'next_page') }

    it 'returns query variables based on entity information' do
      expected = { full_path: entity.source_full_path, cursor: entity.next_page_for }

      expect(described_class.variables(entity)).to eq(expected)
    end
  end

  describe '#data_path' do
    it 'returns data path' do
      expected = %w[data group epics nodes]

      expect(described_class.data_path).to eq(expected)
    end
  end

  describe '#page_info_path' do
    it 'returns pagination information path' do
      expected = %w[data group epics page_info]

      expect(described_class.page_info_path).to eq(expected)
    end
  end
end
