# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['SecurityReportSummarySection'] do
  specify { expect(described_class.graphql_name).to eq('SecurityReportSummarySection') }

  it 'has specific fields' do
    expected_fields = %w[vulnerabilities_count scanned_resources_count scanned_resources scans]

    expect(described_class).to include_graphql_fields(*expected_fields)
  end
end
