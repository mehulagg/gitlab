# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['PushRules'] do
  it { expect(described_class.graphql_name).to eq('PushRules') }

  it { expect(described_class).to require_graphql_authorizations(:read_project) }

  it 'has the expected fields' do
    expect(described_class).to have_graphql_fields(:reject_unsigned_commits)
  end
end
