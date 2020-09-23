# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['MoveType'] do
  it { expect(described_class.graphql_name).to eq('MoveType') }

  it 'exposes all the existing move values' do
    expect(described_class.values.keys).to include(*%w[before after])
  end
end
