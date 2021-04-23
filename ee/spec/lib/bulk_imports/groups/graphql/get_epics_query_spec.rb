# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BulkImports::Groups::Graphql::GetEpicsQuery do
  it 'has a valid query' do
    context = BulkImports::Pipeline::Context.new(create(:bulk_import_tracker))

    result = GitlabSchema.execute(
      described_class.to_s,
      variables: described_class.variables(context)
    ).to_h

    expect(result['errors']).to be_blank
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
