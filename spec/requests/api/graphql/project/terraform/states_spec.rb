# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'query terraform states' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:terraform_state) { create(:terraform_state, :with_version, :locked, project: project) }
  let_it_be(:latest_version) { terraform_state.latest_version }

  let(:query) do
    graphql_query_for(:project, { fullPath: project.full_path },
    %{
      terraformStates {
        count
        nodes {
          id
          name
          lockedAt
          createdAt
          updatedAt

          latestVersion {
            id
            createdAt
            updatedAt

            createdByUser {
              id
            }

            job {
              name
            }
          }

          lockedByUser {
            id
          }
        }
      }
    })
  end

  let(:current_user) { project.creator }
  let(:data) { graphql_data.dig('project', 'terraformStates') }

  before do
    post_graphql(query, current_user: current_user)
  end

  it 'returns terraform state data', :aggregate_failures do
    expect(data['nodes']).to contain_exactly({
      'id'            => global_id_of(terraform_state),
      'name'          => terraform_state.name,
      'lockedAt'      => terraform_state.locked_at.iso8601,
      'createdAt'     => terraform_state.created_at.iso8601,
      'updatedAt'     => terraform_state.updated_at.iso8601,
      'lockedByUser'  => { 'id' => global_id_of(terraform_state.locked_by_user) },
      'latestVersion' => {
        'id'            => eq(latest_version.to_global_id.to_s),
        'createdAt'     => eq(latest_version.created_at.iso8601),
        'updatedAt'     => eq(latest_version.updated_at.iso8601),
        'createdByUser' => { 'id' => eq(latest_version.created_by_user.to_global_id.to_s) },
        'job'           => { 'name' => eq(latest_version.build.name) }
      }
    })
  end

  it 'returns count of terraform states' do
    count = data.dig('count')
    expect(count).to be(project.terraform_states.size)
  end

  context 'unauthorized users' do
    let(:current_user) { nil }

    it { expect(data).to be_nil }
  end
end
