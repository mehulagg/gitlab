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
      ends_at
      length
      length_unit
      participants
      active_period
      shifts
    ]

    expect(described_class).to have_graphql_fields(*expected_fields)
  end

  it 'returns enough records to cover 2 weeks of hour-long shifts' do
    expect(described_class::MAX_SHIFTS_FOR_TIMEFRAME).to be > 14 * 24 # 14 days * 24 hours
    expect(described_class).to have_graphql_field(:shifts, max_page_size: described_class::MAX_SHIFTS_FOR_TIMEFRAME)
  end
end
