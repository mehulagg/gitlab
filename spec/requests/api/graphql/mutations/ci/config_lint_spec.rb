# frozen_string_literal: true
require "spec_helper"

RSpec.describe 'Linting CI Config' do
  include GraphqlHelpers
  include WorkhorseHelpers

  let(:current_user) { create(:user) }

  let(:mutation) do
    input = {
      content: content
    }
    graphql_mutation(:config_lint, input,
                     <<-QL
                        errors
                        status
                        stages {
                          name
                          groups {
                            name
                            jobs {
                              name
                              needs {
                                name
                              }
                            }
                          }
                        }
                     QL
    )
  end

  let(:mutation_response) { graphql_mutation_response(:config_lint) }

  def mutation_response_stages
    mutation_response['stages'].map { |stage| stage['name'] }
  end

  def mutation_response_groups
    mutation_response['stages'].map { |stage| stage['groups'] }.flatten.map { |group| group['name'] }
  end

  def mutation_response_job_name
    mutation_response['stages'].first['groups'].first['name']
  end

  def mutation_response_needs
    mutation_response['stages'].last['groups'].first['jobs'][0]['needs']
  end

  context 'with a valid .gitlab-ci.yml' do
    let_it_be(:content) do
      File.read(Rails.root.join('spec/support/gitlab_stubs/gitlab_ci_includes.yml'))
    end

    it 'lints the ci config file' do
      post_graphql_mutation(mutation)

      expect(mutation_response['status']).to eq('valid')
      expect(graphql_errors).not_to be_present
      expect(response).to have_gitlab_http_status(:success)
    end

    it 'returns the correct structure' do
      post_graphql_mutation(mutation)

      expect(mutation_response_stages).to contain_exactly("build", "test")
      expect(mutation_response_groups).to contain_exactly("docker", "rspec", "spinach")
      expect(mutation_response_job_name).to eq('rspec')
      expect(mutation_response_needs).to eq([{ "name" => "spinach" }, { "name" => "rspec 0 1" }])
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
