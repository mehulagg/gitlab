# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['SastCiConfigurationInput'] do
  it { expect(described_class.graphql_name).to eq('SastCiConfigurationInput') }

  it { expect(described_class.arguments.keys).to match_array(%w[global pipeline analyzers]) }
end
