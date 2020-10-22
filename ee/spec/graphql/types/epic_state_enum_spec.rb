# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['EpicState'] do
  it { expect(described_class.graphql_name).to eq('EpicState') }

  it 'exposes all the existing epic states' do
    expect(described_class.values.keys).to include(*%w[all opened closed])
  end
end
