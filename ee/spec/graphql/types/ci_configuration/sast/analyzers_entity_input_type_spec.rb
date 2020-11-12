# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['SastCiConfigurationAnalyzersEntityInput'] do
  it { expect(described_class.graphql_name).to eq('SastCiConfigurationAnalyzersEntityInput') }

  it { expect(described_class.arguments.keys).to match_array(%w[enabled name variables]) }
end
