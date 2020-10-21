# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query.project(fullPath).pipelines' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project, :repository, :public) }
  let_it_be(:user) { create(:user) }

  describe '.jobs(securityReportTypes)' do
    let_it_be(:query) do
      %(
        query {
          project(fullPath: "#{project.full_path}") {
            pipelines {
              nodes {
                jobs(securityReportTypes: [SAST]) {
                  nodes {
                    name
                  }
                }
              }
            }
          }
        }
      )
    end

    it 'fetches the jobs without an N+1' do
      pipeline = create(:ci_pipeline, project: project)
      create(:ci_build, :dast, name: 'DAST Job 1', pipeline: pipeline)
      create(:ci_build, :sast, name: 'SAST Job 1', pipeline: pipeline)

      control_count = ActiveRecord::QueryRecorder.new do
        post_graphql(query, current_user: user)
      end

      pipeline = create(:ci_pipeline, project: project)
      create(:ci_build, :dast, name: 'DAST Job 2', pipeline: pipeline)
      create(:ci_build, :sast, name: 'SAST Job 2', pipeline: pipeline)

      expect do
        post_graphql(query, current_user: user)
      end.not_to exceed_query_limit(control_count)

      expect(response).to have_gitlab_http_status(:ok)

      pipelines_data = graphql_data.dig('project', 'pipelines', 'nodes')

      job_names = pipelines_data.map do |pipeline_data|
        jobs_data = pipeline_data.dig('jobs', 'nodes')
        jobs_data.map { |job_data| job_data['name'] }
      end.flatten

      expect(job_names).to contain_exactly('SAST Job 1', 'SAST Job 2')
    end
  end
end
