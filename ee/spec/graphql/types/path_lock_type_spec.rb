# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['PathLock'] do
  it { expect(described_class.graphql_name).to eq('PathLock') }

  it 'has the expected fields' do
    expect(described_class).to have_graphql_fields(:id, :path, :user)
  end
end
