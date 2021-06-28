# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'CiJobTokenScopeRemoveProject' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project, ci_job_token_scope_enabled: true).tap(&:save!) }
  let_it_be(:target_project) { create(:project) }

  let_it_be(:link) do
    create(:ci_job_token_project_scope_link,
      source_project: project,
      target_project: target_project)
  end

  let(:variables) do
    {
      project_path: project.full_path,
      target_project_path: target_project.full_path
    }
  end

  let(:mutation) do
    graphql_mutation(:ci_job_token_scope_remove_project, variables) do
      <<~QL
        errors
        ciJobTokenScope {
          projects {
            nodes {
              path
            }
          }
        }
      QL
    end
  end

  let(:mutation_response) { graphql_mutation_response(:ci_job_token_scope_remove_project) }

  context 'when unauthorized' do
    let(:current_user) { create(:user) }

    context 'when not a maintainer' do
      before do
        project.add_developer(current_user)
      end

      it 'has graphql errors' do
        post_graphql_mutation(mutation, current_user: current_user)

        expect(graphql_errors).not_to be_empty
      end
    end
  end

  context 'when authorized' do
    let_it_be(:current_user) { project.owner }

    before do
      target_project.add_guest(current_user)
    end

    it 'temporarily disables the operation' do
      post_graphql_mutation(mutation, current_user: current_user)
      expect(response).to have_gitlab_http_status(:success)
      expect(mutation_response.dig('ciJobTokenScope', 'projects', 'nodes')).to be_nil
    end

    context 'when invalid target project is provided' do
      before do
        variables[:target_project_path] = 'unknown/project'
      end

      it 'has mutation errors' do
        post_graphql_mutation(mutation, current_user: current_user)

        expect(mutation_response['errors']).to contain_exactly('Job token scope is disabled for this project')
      end
    end
  end
end
