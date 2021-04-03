# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'DevopsAdoptionSegments' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user, :admin) }
  let_it_be(:group) { create(:group, name: 'my-group') }

  let_it_be(:segment) do
    create(:devops_adoption_segment, namespace: group).tap do |segment|
      create(:devops_adoption_snapshot, segment: segment, issue_opened: true, merge_request_opened: false)
    end
  end

  let(:query) do
    graphql_query_for(:devopsAdoptionSegments, {}, %(
      nodes {
        id
        namespace {
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
    post_graphql(query, current_user: current_user)
  end

  it 'returns measurement objects' do
    expect(graphql_data['devopsAdoptionSegments']['nodes']).to eq([
      {
        'id' => segment.to_gid.to_s,
        'namespace' => { 'name' => group.name },
        'latestSnapshot' => {
          'mergeRequestOpened' => false,
          'issueOpened' => true
        }
      }
    ])
  end
end
