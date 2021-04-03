# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['BoardEpicUserPreferences'] do
  it { expect(described_class.graphql_name).to eq('BoardEpicUserPreferences') }

  it 'has specific fields' do
    expect(described_class).to have_graphql_field(:collapsed)
  end
end
