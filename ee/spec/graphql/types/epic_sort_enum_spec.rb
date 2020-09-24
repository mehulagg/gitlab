# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['EpicSort'] do
  it { expect(described_class.graphql_name).to eq('EpicSort') }

  it 'exposes all the existing epic sort orders' do
    expect(described_class.values.keys).to include(*%w[start_date_desc start_date_asc end_date_desc end_date_asc])
  end
end
