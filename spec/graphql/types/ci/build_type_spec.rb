# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Ci::BuildType do
  specify { expect(described_class.graphql_name).to eq('CiBuild') }

  specify { expect(described_class).to require_graphql_authorizations(:read_build) }

  it 'has specific fields' do
    fields = %i[
      id name stage allow_failure status duration
      created_at started_at finished_at
      trace
    ]

    fields.each do |field_name|
      expect(described_class).to have_graphql_field(field_name)
    end
  end
end
