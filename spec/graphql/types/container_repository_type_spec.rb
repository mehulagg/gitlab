# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['ContainerRepository'] do
  fields = %i[id name path location created_at updated_at status tags_count]

  it { expect(described_class.graphql_name).to eq('ContainerRepository') }

  it { expect(described_class.description).to eq('A container repository') }

  it { expect(described_class).to require_graphql_authorizations(:read_container_image) }

  it { expect(described_class).to have_graphql_fields(fields) }

  describe 'status field' do
    subject { described_class.fields['status'] }

    it 'returns status enum' do
      is_expected.to have_graphql_type(Types::ContainerRepositoryStatusEnum)
    end
  end
end
