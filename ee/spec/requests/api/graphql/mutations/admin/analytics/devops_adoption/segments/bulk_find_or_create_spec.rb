# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Admin::Analytics::DevopsAdoption::Segments::BulkFindOrCreate do
  include GraphqlHelpers

  let_it_be(:admin) { create(:admin) }
  let_it_be(:group) { create(:group, name: 'aaaa') }
  let_it_be(:group2) { create(:group, name: 'bbbb') }
  let_it_be(:group3) { create(:group, name: 'cccc') }
  let_it_be(:existing_segment) { create :devops_adoption_segment, namespace: group3 }

  let(:variables) { { namespace_ids: [group.to_gid.to_s, group2.to_gid.to_s, group3.to_gid.to_s] } }

  let(:mutation) do
    graphql_mutation(:bulk_find_or_create_devops_adoption_segments, variables) do
      <<-QL.strip_heredoc
        clientMutationId
        errors
        segments {
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
    graphql_mutation_response(:bulk_find_or_create_devops_adoption_segments)
  end

  before do
    stub_licensed_features(instance_level_devops_adoption: true)
  end

  it_behaves_like 'DevOps Adoption top level errors'

  it 'creates the segment for each passed namespace or returns existing segment' do
    post_graphql_mutation(mutation, current_user: admin)

    expect(mutation_response['errors']).to be_empty

    segments = mutation_response['segments']
    expect(segments.map { |s| s['namespace']['name'] }).to match_array(%w[aaaa bbbb cccc])
    expect(segments.map { |s| s['id'] }).to include(existing_segment.to_gid.to_s)
    expect(::Analytics::DevopsAdoption::Segment.joins(:namespace)
                                               .where(namespaces: { name: %w[aaaa bbbb cccc] }).count).to eq(3)
  end
end
