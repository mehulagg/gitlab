# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Analytics::DevopsAdoption::Segments::BulkFindOrCreate do
  include GraphqlHelpers

  let_it_be(:display_group) { create(:group, name: 'dddd') }
  let_it_be(:group) { create(:group, name: 'aaaa', parent: display_group) }
  let_it_be(:group2) { create(:group, name: 'bbbb', parent: display_group) }
  let_it_be(:group3) { create(:group, name: 'cccc', parent: display_group) }

  let_it_be(:reporter) do
    create(:user).tap do |u|
      display_group.add_reporter(u)
      group.add_reporter(u)
      group2.add_reporter(u)
      group3.add_reporter(u)
    end
  end

  let_it_be(:existing_segment) { create :devops_adoption_segment, namespace: group3, display_namespace: display_group }

  let(:current_user) { reporter }

  let(:variables) { { namespace_ids: [group.to_gid.to_s, group2.to_gid.to_s, group3.to_gid.to_s], display_namespace_id: display_group.to_gid.to_s } }

  let(:mutation) do
    graphql_mutation(:bulk_find_or_create_devops_adoption_segments, variables) do
      <<-QL.strip_heredoc
        clientMutationId
        errors
        segments {
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
    graphql_mutation_response(:bulk_find_or_create_devops_adoption_segments)
  end

  before do
    stub_licensed_features(group_level_devops_adoption: true)
  end

  context 'when the user cannot manage segments at least for one namespace' do
    let(:current_user) { create(:user).tap { |u| group.add_reporter(u) } }

    it_behaves_like 'a mutation that returns a top-level access error'
  end

  context 'when the feature is not available' do
    before do
      stub_licensed_features(group_level_devops_adoption: false)
    end

    it_behaves_like 'a mutation that returns a top-level access error'
  end

  it 'creates the segment for each passed namespace or returns existing segment' do
    post_graphql_mutation(mutation, current_user: current_user)

    expect(mutation_response['errors']).to be_empty

    segments = mutation_response['segments']
    expect(segments.map { |s| s['namespace']['name'] }).to match_array(%w[aaaa bbbb cccc])
    expect(segments.map { |s| s['displayNamespace']['name'] }).to match_array(%w[dddd dddd dddd])
    expect(segments.map { |s| s['id'] }).to include(existing_segment.to_gid.to_s)
    expect(::Analytics::DevopsAdoption::Segment.joins(:namespace)
                                               .where(namespaces: { name: %w[aaaa bbbb cccc] }).count).to eq(3)
  end
end
