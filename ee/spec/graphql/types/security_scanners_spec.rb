# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['SecurityScanners'] do
  specify { expect(described_class.graphql_name).to eq('SecurityScanners') }

  it 'has specific fields' do
    expected_fields = %w[enabled available pipelineRun]

    expect(described_class).to include_graphql_fields(*expected_fields)
  end
end
