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

  it 'fetches the artifacts without an N+1' do
    pipeline = create(:ci_pipeline, project: project)
    job = create(:ci_build, pipeline: pipeline)
    artifact = create(:ci_job_artifact, job: job)

    control_count = ActiveRecord::QueryRecorder.new do
      post_graphql(query, current_user: first_user)
    end

    pipeline = create(:ci_pipeline, project: project)
    job = create(:ci_build, pipeline: pipeline)
    job_2 = create(:ci_build, pipeline: pipeline)
    artifact_2 = create(:ci_job_artifact, job: job)
    artifact_3 = create(:ci_job_artifact, :archive, job: job_2)
    artifact_4 = create(:ci_job_artifact, :trace, job: job_2)

    expect do
      post_graphql(query, current_user: second_user)
    end.not_to exceed_query_limit(control_count)

    expect(response).to have_gitlab_http_status(:ok)

    pipelines_data = graphql_data.dig('project', 'pipelines', 'nodes')
    jobs_data = pipelines_data.map { |pipe_data| pipe_data.dig('jobs', 'nodes') }.flatten
    artifacts_data = jobs_data.map { |job_data| job_data.dig('artifacts', 'nodes') }.flatten
    artifact_ids = artifacts_data.map { |art_data| art_data['id'] }
    expect(artifact_ids).to contain_exactly(
      artifact.to_global_id.to_s,
      artifact_2.to_global_id.to_s,
      artifact_3.to_global_id.to_s,
      artifact_4.to_global_id.to_s
    )
  end
end
