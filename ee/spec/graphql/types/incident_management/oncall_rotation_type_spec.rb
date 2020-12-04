# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['IncidentManagementOncallRotation'] do
  specify { expect(described_class.graphql_name).to eq('IncidentManagementOncallRotation') }

  specify { expect(described_class).to require_graphql_authorizations(:read_incident_management_oncall_schedule) }

  it 'exposes the expected fields' do
    expected_fields = %i[
      id
      name
      starts_at
      rotation_length
      rotation_length_unit
      participants
    ]

    expect(described_class).to have_graphql_fields(*expected_fields)
  end
end
