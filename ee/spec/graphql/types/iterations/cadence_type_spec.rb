# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['IterationCadence'] do
  let(:fields) do
    %i[id title duration_in_weeks iterations_in_advance start_date automatic active roll_over description]
  end

  specify { expect(described_class.graphql_name).to eq('IterationCadence') }

  specify { expect(described_class).to have_graphql_fields(fields) }

  specify { expect(described_class).to require_graphql_authorizations(:read_iteration_cadence) }
end
