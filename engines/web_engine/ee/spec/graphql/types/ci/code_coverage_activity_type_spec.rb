# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['CodeCoverageActivity'] do
  let(:fields) { %i[average_coverage coverage_count project_count date] }

  it { expect(described_class.graphql_name).to eq('CodeCoverageActivity') }

  it { expect(described_class).to have_graphql_fields(fields) }
end
