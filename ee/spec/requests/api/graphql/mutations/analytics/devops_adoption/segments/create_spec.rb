# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Analytics::DevopsAdoption::Segments::Create do
  include GraphqlHelpers

  let_it_be(:display_group) { create(:group, name: 'aaaa') }
  let_it_be(:group) { create(:group, name: 'bbbb', parent: display_group) }

  let_it_be(:reporter) do
    create(:user).tap do |u|
      group.add_reporter(u)
      display_group.add_reporter(u)
    end
  end

  let(:current_user) { reporter }

  let(:variables) { { namespace_id: group.to_gid.to_s, display_namespace_id: display_group.to_gid.to_s } }

  let(:mutation) do
    graphql_mutation(:create_devops_adoption_segment, variables) do
      <<-QL.strip_heredoc
        clientMutationId
        errors
        segment {
          id
          namespace {
            name
          }
          displayNamespace {
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
    stub_licensed_features(group_level_devops_adoption: true)
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

  it 'creates the segment with the group', :aggregate_failures do
    post_graphql_mutation(mutation, current_user: current_user)

    expect(mutation_response['errors']).to be_empty

    segment = mutation_response['segment']
    expect(segment['namespace']['name']).to eq('bbbb')
    expect(segment['displayNamespace']['name']).to eq('aaaa')
    expect(::Analytics::DevopsAdoption::Segment.joins(:namespace).where(namespaces: { name: 'bbbb' }).count).to eq(1)
  end
end
