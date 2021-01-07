# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['MetricImage'] do
  it { expect(described_class.graphql_name).to eq('MetricImage') }

  it { expect(described_class).to require_graphql_authorizations(:read_issuable_metric_image) }

  it 'has the expected fields' do
    expected_fields = %w[
      id iid url file_name file_path
    ]

    expect(described_class).to have_graphql_fields(*expected_fields).at_least
  end
end
