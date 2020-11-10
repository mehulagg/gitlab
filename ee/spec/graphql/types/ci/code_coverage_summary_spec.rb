# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['CodeCoverageSummary'] do
  it { expect(described_class.graphql_name).to eq('CodeCoverageSummary') }

  describe 'fields' do
    let(:fields) { %i[average_coverage coverage_count last_updated_on] }

    it { expect(described_class).to have_graphql_fields(fields) }
  end
end
