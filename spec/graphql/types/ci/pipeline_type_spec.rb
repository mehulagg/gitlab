# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Types::Ci::PipelineType do
  specify { expect(described_class.graphql_name).to eq('Pipeline') }

  specify { expect(described_class).to expose_permissions_using(Types::PermissionTypes::Ci::Pipeline) }

  specify { expect(described_class).to require_graphql_authorizations(:read_pipeline) }

  it 'has specific fields' do
    fields = %i[
      id
      builds build
    ]

    fields.each do |field_name|
      expect(described_class).to have_graphql_field(field_name)
    end
  end
end
