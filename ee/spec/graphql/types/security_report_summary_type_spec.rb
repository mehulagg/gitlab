# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['SecurityReportSummary'] do
  specify { expect(described_class.graphql_name).to eq('SecurityReportSummary') }

  it 'has specific fields' do
    expected_fields = %w[dast sast containerScanning dependencyScanning clusterImageScanning]

    expect(described_class).to include_graphql_fields(*expected_fields)
  end
end
