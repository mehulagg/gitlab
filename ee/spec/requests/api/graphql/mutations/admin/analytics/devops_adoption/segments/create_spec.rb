# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Admin::Analytics::DevopsAdoption::Segments::Create do
  include GraphqlHelpers

  let_it_be(:admin) { create(:admin) }
  let_it_be(:group_1) { create(:group, name: 'bbbb') }
  let(:variables) { { namespace_id: group_1.to_gid.to_s } }

  let(:mutation) do
    graphql_mutation(:create_devops_adoption_segment, variables) do
      <<-QL.strip_heredoc
        clientMutationId
        errors
        segment {
          id
          namespace {
            id
            name
          }
        }
      QL
    end
  end

  def mutation_response
    graphql_mutation_response(:create_devops_adoption_segment)
  end

  before do
    stub_licensed_features(instance_level_devops_adoption: true)
  end

  it_behaves_like 'DevOps Adoption top level errors'

  it 'creates the segment with the group' do
    post_graphql_mutation(mutation, current_user: admin)

    expect(mutation_response['errors']).to be_empty

    segment = mutation_response['segment']
    expect(segment['namespace']['name']).to eq('bbbb')
  end
end
