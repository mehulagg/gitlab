# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DevopsAdoptionSegments' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user, :admin) }
  let_it_be(:group) { create(:group, name: 'my-group') }

  let_it_be(:segment) do
    create(:devops_adoption_segment, namespace: group, display_namespace: group)
  end

  let_it_be(:snapshot) do
    create(:devops_adoption_snapshot, namespace: group, issue_opened: true, merge_request_opened: false)
  end

  let(:query) do
    graphql_query_for(:devopsAdoptionSegments, { display_namespace_id: group.to_gid.to_s }, %(
      nodes {
        id
        namespace {
          name
        }
        displayNamespace {
          name
        }
        latestSnapshot {
          issueOpened
          mergeRequestOpened
        }
      }
    ))
  end

  before do
    stub_licensed_features(instance_level_devops_adoption: true, group_level_devops_adoption: true)

    post_graphql(query, current_user: current_user)
  end

  it 'returns measurement objects' do
    expect(graphql_data['devopsAdoptionSegments']['nodes']).to eq([
      {
        'id' => segment.to_gid.to_s,
        'namespace' => { 'name' => group.name },
        'displayNamespace' => { 'name' => group.name },
        'latestSnapshot' => {
          'mergeRequestOpened' => false,
          'issueOpened' => true
        }
      }
    ])
  end
end
