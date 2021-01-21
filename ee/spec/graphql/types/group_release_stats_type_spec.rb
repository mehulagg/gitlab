# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['GroupReleaseStats'] do
  it { expect(described_class).to require_graphql_authorizations(:read_group_release_stats) }

  it 'has the expected fields' do
    expected_fields = %w[releasesCount releasesPercentage]

    expect(described_class).to include_graphql_fields(*expected_fields)
  end
end
