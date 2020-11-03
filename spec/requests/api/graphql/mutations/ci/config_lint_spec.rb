# frozen_string_literal: true
require "spec_helper"

RSpec.describe 'Linting CI Config' do
  include GraphqlHelpers
  include WorkhorseHelpers

  let(:current_user) { create(:user) }

  let(:mutation) do
    input = {
      content: content.dup,
    }
    graphql_mutation(:config_lint, input, 'errors')
  end

  let(:mutation_response) { graphql_mutation_response(:config_lint) }

  context 'with a valid .gitlab-ci.yml' do
    let_it_be(:content) {
      fixture_file_upload('spec/support/gitlab_stubs/gitlab_ci.yml')
    }

    it 'lints the ci config file' do
      post_graphql_mutation_with_uploads(mutation)

      expect(graphql_errors).not_to be_present
      expect(response).to have_gitlab_http_status(:success)
    end
  end

  context 'with invalid .gitlab-ci.yml' do
    let_it_be(:content) { 'invalid' }

    it 'responds with errors about invalid syntax' do
      post_graphql_mutation_with_uploads(mutation)

      expect(graphql_errors).to be_present
      expect(response).to have_gitlab_http_status(:ok)
    end
  end
end
