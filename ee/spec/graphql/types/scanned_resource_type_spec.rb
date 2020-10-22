# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['ScannedResource'] do
  specify { expect(described_class.graphql_name).to eq('ScannedResource') }

  it 'has specific fields' do
    expected_fields = %w[url request_method]

    expect(described_class).to include_graphql_fields(*expected_fields)
  end
end
