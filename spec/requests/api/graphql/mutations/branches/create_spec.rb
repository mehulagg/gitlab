# frozen_string_literal: true

require 'spec_helper'

describe 'Creation of a new branch' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let(:project) { create(:project, :public, :repository) }
  let(:input) { { project_path: project.full_path, name: new_branch, ref: ref } }
  let(:new_branch) { 'new_branch' }
  let(:ref) { 'master' }

  let(:mutation) { graphql_mutation(:create_branch, input) }
  let(:mutation_response) { graphql_mutation_response(:create_branch) }

  context 'the user is not allowed to create a branch' do
    it_behaves_like 'a mutation that returns top-level errors',
      errors: ['The resource that you are attempting to access does not exist or you don\'t have permission to perform this action']
  end

  context 'when user has permissions to create a branch' do
    before do
      project.add_developer(current_user)
    end

    it 'creates a new branch' do
      post_graphql_mutation(mutation, current_user: current_user)

      expect(response).to have_gitlab_http_status(:success)
      expect(mutation_response['branch']).to include(
        'name' => new_branch,
        'commit' => a_hash_including('id')
      )
    end

    context 'when ref is not correct' do
      let(:ref) { 'unknown' }

      it_behaves_like 'a mutation that returns errors in the response',
                      errors: ['Invalid reference name: new_branch']
    end
  end
end
