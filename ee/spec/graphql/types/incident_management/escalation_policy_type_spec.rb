# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['EscalationPolicyType'] do
  specify { expect(described_class.graphql_name).to eq('EscalationPolicyType') }

  specify { expect(described_class).to require_graphql_authorizations(:read_incident_management_escalation_policy) }

  it 'exposes the expected fields' do
    expected_fields = %i[
      id
      name
      description
      rules
    ]

    expect(described_class).to have_graphql_fields(*expected_fields)
  end
end
