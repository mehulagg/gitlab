# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'getting pipeline information nested in a project' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project, :repository, :public) }
  let_it_be(:pipeline) { create(:ci_pipeline, project: project) }
  let_it_be(:current_user) { create(:user) }
  let_it_be(:build_job) { create(:ci_build, :trace_with_sections, pipeline: pipeline) }

  let(:path) { %i[project pipeline] }
  let(:pipeline_graphql_data) { graphql_data_at(*path) }
  let(:depth) { 3 }
  let(:fields) { all_graphql_fields_for('Pipeline', excluded: ['build'], max_depth: depth) }

  let(:query) do
    graphql_query_for(
      'project',
      { 'fullPath' => project.full_path },
      query_graphql_field('pipeline', { iid: pipeline.iid.to_s }, fields)
    )
  end

  it_behaves_like 'a working graphql query' do
    before do
      post_graphql(query, current_user: current_user)
    end
  end

  it 'contains pipeline information' do
    post_graphql(query, current_user: current_user)

    expect(pipeline_graphql_data).not_to be_nil
  end

  it 'contains configSource' do
    post_graphql(query, current_user: current_user)

    expect(pipeline_graphql_data.dig('configSource')).to eq('UNKNOWN_SOURCE')
  end

  context 'When enough data is requested' do
    let(:depth) { 5 }

    it 'contains builds' do
      post_graphql(query, current_user: current_user)

      expect(graphql_data_at(*path, :builds, :nodes)).to contain_exactly(
        a_graphql_object_with(
          name: build_job.name,
          status: build_job.status.upcase,
          duration: build_job.duration,
          trace: a_graphql_object_with(
            raw: build_job.trace.raw,
            html: build_job.trace.html,
            sections: build_job.trace.extract_sections.map do |s|
              a_graphql_object_with(s.merge(content: String))
            end
          )
        )
      )
    end
  end

  context 'when requesting a specific build' do
    let(:variables) do
      {
        path: project.full_path,
        pipelineIID: pipeline.iid.to_s
      }
    end

    let(:query) do
      <<~GQL
      query($path: ID!, $pipelineIID: ID!, $jobName: String, $jobID: CiBuildID) {
        project(fullPath: $path) {
          pipeline(iid: $pipelineIID) {
            build(id: $jobID, name: $jobName) {
              #{all_graphql_fields_for('CiBuild', max_depth: 1)}
            }
          }
        }
      }
      GQL
    end

    let(:the_job) do
      a_graphql_object_with(name: build_job.name, id: global_id_of(build_job))
    end

    it 'can request a build by name' do
      vars = variables.merge(jobName: build_job.name)

      post_graphql(query, current_user: current_user, variables: vars)

      expect(graphql_data_at(*path)).to match(a_graphql_object_with(build: the_job))
    end

    it 'can request a build by ID' do
      vars = variables.merge(jobID: global_id_of(build_job))

      post_graphql(query, current_user: current_user, variables: vars)

      expect(graphql_data_at(*path)).to match(a_graphql_object_with(build: the_job))
    end
  end
end
