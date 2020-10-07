# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Ci::TraceSectionType do
  specify { expect(described_class.graphql_name).to eq('BuildSection') }

  it 'has specific fields' do
    fields = %i[
      name byte_start byte_end date_start date_end content
    ]

    fields.each do |field_name|
      expect(described_class).to have_graphql_field(field_name)
    end
  end
end
