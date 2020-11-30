# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['AlertManagementViewFilter'] do
  specify { expect(described_class.graphql_name).to eq('AlertManagementViewFilter') }

  it 'exposes all the severity values' do
    expect(described_class.values.keys).to include(*%w[THREAT_MONITORING OPERATIONS])
  end
end
