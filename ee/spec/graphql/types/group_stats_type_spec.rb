# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['GroupStats'] do
  it { expect(described_class).to require_graphql_authorizations(:read_group) }

  it 'has the expected fields' do
    expected_fields = %w[releaseStats]

    expect(described_class).to include_graphql_fields(*expected_fields)
  end
end
