# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Analytics::DevopsAdoption::Segments::Delete do
  include GraphqlHelpers

  let_it_be(:display_group) { create :group }
  let_it_be(:group) { create :group, parent: display_group }
  let_it_be(:reporter) do
    create(:user).tap do |u|
      display_group.add_reporter(u)
      group.add_reporter(u)
    end
  end

  let(:current_user) { reporter }
  let!(:segment) { create(:devops_adoption_segment, namespace: group, display_namespace: display_group) }

  let(:variables) { { id: segment.to_gid.to_s } }

  let(:mutation) do
    graphql_mutation(:delete_devops_adoption_segment, variables) do
      <<~QL
        clientMutationId
        errors
      QL
    end
  end

  before do
    stub_licensed_features(group_level_devops_adoption: true)
  end

  def mutation_response
    graphql_mutation_response(:delete_devops_adoption_segment)
  end

  context 'when the user cannot manage segments' do
    let(:current_user) { create(:user) }

    it_behaves_like 'a mutation that returns a top-level access error'
  end

  context 'when the feature is not available' do
    before do
      stub_licensed_features(group_level_devops_adoption: false)
    end

    it_behaves_like 'a mutation that returns a top-level access error'
  end

  it 'deletes the segment' do
    post_graphql_mutation(mutation, current_user: current_user)

    expect(mutation_response['errors']).to be_empty
    expect(::Analytics::DevopsAdoption::Segment.find_by_id(segment.id)).to eq(nil)
  end

  context 'with bulk ids' do
    let!(:segment2) { create(:devops_adoption_segment) }
    let!(:segment3) { create(:devops_adoption_segment) }

    let(:variables) { { id: [segment.to_gid.to_s, segment2.to_gid.to_s] } }

    before do
      segment2.namespace.add_reporter(current_user)
      segment2.display_namespace.add_reporter(current_user)
      segment3.namespace.add_reporter(current_user)
      segment3.display_namespace.add_reporter(current_user)
    end

    it 'deletes the segments specified for deletion' do
      post_graphql_mutation(mutation, current_user: current_user)

      expect(mutation_response['errors']).to be_empty
      expect(::Analytics::DevopsAdoption::Segment.where(id: [segment.id, segment2.id, segment3.id]))
        .to match_array([segment3])
    end
  end
end
