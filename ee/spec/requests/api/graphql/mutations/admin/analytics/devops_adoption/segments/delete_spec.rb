# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Admin::Analytics::DevopsAdoption::Segments::Delete do
  include GraphqlHelpers

  let_it_be(:admin) { create(:admin) }
  let_it_be(:group_1) { create(:group, name: 'bbbb') }

  let(:segment) { create(:devops_adoption_segment, name: 'my segment') }
  let(:variables) { { id: segment.to_gid.to_s } }

  let(:mutation) do
    graphql_mutation(:delete_devops_adoption_segment, variables,
                     <<-QL.strip_heredoc
                       clientMutationId
                       errors
    QL
    )
  end

  before do
    stub_licensed_features(instance_level_devops_adoption: true)

    create(:devops_adoption_segment_selection, :group, segment: segment, group: group_1)
  end

  def mutation_response
    graphql_mutation_response(:delete_devops_adoption_segment)
  end

  it_behaves_like 'DevOps Adoption top level errors'

  it 'deletes the segments' do
    post_graphql_mutation(mutation, current_user: admin)

    expect(mutation_response['errors']).to be_empty
    expect(::Analytics::DevopsAdoption::Segment.find_by_id(segment.id)).to eq(nil)
  end
end
