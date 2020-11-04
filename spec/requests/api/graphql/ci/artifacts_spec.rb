# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Query.project.pipeline.jobs.artifacts' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project, :repository, :public) }
  let_it_be(:first_user) { create(:user) }
  let_it_be(:second_user) { create(:user) }

  let_it_be(:query) do
    %(
      query {
        project(fullPath: "#{project.full_path}") {
          pipelines {
            nodes {
              jobs {
                nodes {
                  artifacts {
                    nodes {
                      id
                    }
                  }
                }
              }
            }
          }
        }
      }
    )
  end

  it 'fetches the artifacts' do
    pipeline = create(:ci_pipeline, project: project)
    job = create(:ci_build, pipeline: pipeline)
    artifact = create(:ci_job_artifact, job: job)

    post_graphql(query, current_user: first_user)

    expect(response).to have_gitlab_http_status(:ok)

    pipelines_data = graphql_data.dig('project', 'pipelines', 'nodes')
    jobs_data = pipelines_data.map { |pipe_data| pipe_data.dig('jobs', 'nodes') }.flatten
    artifacts_data = jobs_data.map { |job_data| job_data.dig('artifacts', 'nodes') }.flatten
    artifact_ids = artifacts_data.map { |art_data| art_data['id'] }
    expect(artifact_ids).to contain_exactly(artifact.to_global_id.to_s)
  end
end
