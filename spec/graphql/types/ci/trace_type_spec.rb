# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Ci::TraceType do
  specify { expect(described_class.graphql_name).to eq('BuildTrace') }

  it 'has specific fields' do
    fields = %i[
      raw html sections
    ]

    fields.each do |field_name|
      expect(described_class).to have_graphql_field(field_name)
    end
  end
end
