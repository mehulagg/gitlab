# frozen_string_literal: true
require "spec_helper"

RSpec.describe 'Linting CI Config' do
  include GraphqlHelpers
  include WorkhorseHelpers

  let(:current_user) { create(:user) }

  let(:mutation) do
    input = {
      content: content,
    }
    graphql_mutation(:config_lint, input,
                     <<-QL
                        errors
                        status
                        stages {
                          nodes {
                            name
                            groups {
                              nodes {
                                name
                                jobs {
                                  nodes {
                                    name
                                  }
                                }
                              }
                            }
                          }
                        }
                      QL
                     )
  end

  let(:mutation_response) { graphql_mutation_response(:config_lint) }

  def mutation_response_group
    mutation_response['stages']['nodes'].select { |stage| stage['name'] == 'test' }.first['groups']['nodes']
  end

  def mutation_response_job
    mutation_response_group.first['jobs']['nodes'].first
  end

  context 'with a valid .gitlab-ci.yml' do
    let_it_be(:content) {
      File.read(Rails.root.join('spec/support/gitlab_stubs/gitlab_ci.yml'))
    }

    it 'lints the ci config file' do
      post_graphql_mutation(mutation)

      expect(mutation_response['status']).to eq('valid')
      expect(mutation_response_group.count).to eq(2)
      expect(mutation_response_group.first['name']).to eq('rspec')
      expect(mutation_response_job['name']).to eq('rspec')
      expect(mutation_response['stages']['nodes'].count).to eq(5)
      expect(graphql_errors).not_to be_present
      expect(response).to have_gitlab_http_status(:success)
    end
  end

  context 'with invalid .gitlab-ci.yml' do
    let_it_be(:content) { 'invalid' }

    it 'responds with errors about invalid syntax' do
      post_graphql_mutation(mutation)

      expect(mutation_response['status']).to eq('invalid')
      expect(response).to have_gitlab_http_status(:ok)
    end
  end
end
