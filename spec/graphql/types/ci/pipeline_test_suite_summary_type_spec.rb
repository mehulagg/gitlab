# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Ci::PipelineTestSuiteSummaryType do
  specify { expect(described_class.graphql_name).to eq('PipelineTestSuiteSummary') }

  it 'contains attributes related to a pipeline test report summary' do
    expected_fields = %w[
      name total build_ids
    ]

    expect(described_class).to have_graphql_fields(*expected_fields)
  end
end
