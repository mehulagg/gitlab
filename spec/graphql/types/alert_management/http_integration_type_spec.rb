# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['AlertManagementHttpIntegration'] do
  specify { expect(described_class.graphql_name).to eq('AlertManagementHttpIntegration') }

  specify { expect(described_class).to require_graphql_authorizations(:admin_operations) }

  it 'exposes the expected fields' do
    expected_fields = %i[
      id
      name
      active
      token
      url
    ]

    expect(described_class).to have_graphql_fields(*expected_fields)
  end
end
