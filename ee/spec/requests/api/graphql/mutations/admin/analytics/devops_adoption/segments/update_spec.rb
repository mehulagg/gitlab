# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Admin::Analytics::DevopsAdoption::Segments::Update do
  include GraphqlHelpers

  let_it_be(:admin) { create(:admin) }
  let_it_be(:group_1) { create(:group, name: 'bbbb') }
  let_it_be(:group_2) { create(:group, name: 'cccc') }
  let_it_be(:group_3) { create(:group, name: 'aaaa') }

  let(:segment) { create(:devops_adoption_segment, name: 'my segment') }
  let(:variables) { { id: segment.to_gid.to_s, name: 'new name', group_ids: [group_1.to_gid.to_s, group_2.to_gid.to_s, group_3.to_gid.to_s] } }

  let(:mutation) do
    graphql_mutation(:update_devops_adoption_segment, variables,
                     <<-QL.strip_heredoc
                       clientMutationId
                       errors
                       segment {
                         id
                         name
                         groups {
                           nodes {
                             id
                             name
                           }
                         }
                       }
    QL
    )
  end

  before do
    stub_licensed_features(instance_level_devops_adoption: true)

    create(:devops_adoption_segment_selection, :group, segment: segment, group: group_1)
  end

  def mutation_response
    graphql_mutation_response(:update_devops_adoption_segment)
  end

  it_behaves_like 'DevOps Adoption top level errors'

  it 'updates the segment name and the groups' do
    post_graphql_mutation(mutation, current_user: admin)

    expect(mutation_response['errors']).to be_empty

    segment = mutation_response['segment']
    expect(segment['name']).to eq('new name')

    group_names = segment['groups']['nodes'].map { |node| node['name'] }
    expect(group_names).to match_array(%w[aaaa bbbb cccc])
  end

  context 'when group_ids is missing' do
    before do
      variables.delete(:group_ids)
    end

    it 'does not update the group ids' do
      expect { post_graphql_mutation(mutation, current_user: admin) }.not_to change { segment.segment_selections }
    end
  end

  context 'when group_ids is empty' do
    before do
      variables[:group_ids] = []

      post_graphql_mutation(mutation, current_user: admin)
    end

    it 'removes all selections' do
      expect(mutation_response['segment']['groups']['nodes']).to be_empty
    end
  end
end
