# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query.project.pipeline.job.trace' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project, :repository, :public) }
  let_it_be(:pipeline) { create(:ci_pipeline, project: project) }
  let_it_be(:current_user) { create(:user) }
  let_it_be(:build_job) { create(:ci_build, :trace_with_sections, name: 'build-a', pipeline: pipeline) }

  let(:query) do
    <<~GQL
    query($path: ID!, $pipelineIID: ID!, $jobID: JobID) {
      project(fullPath: $path) {
        pipeline(iid: $pipelineIID) {
          job(id: $jobID) {
            trace { #{trace_fields} }
          }
        }
      }
    }
    GQL
  end

  let(:variables) do
    {
      path: project.full_path,
      pipelineIID: pipeline.iid.to_s,
      jobID: global_id_of(build_job)
    }
  end

  let(:trace_fields) { all_graphql_fields_for('BuildTrace', max_depth: 3) }
  let(:trace_data) { graphql_data_at(:project, :pipeline, :job, :trace) }

  it 'can fetch a trace' do
    post_graphql(query, current_user: current_user, variables: variables)

    expect(trace_data).to match(
      a_graphql_object_with(
        raw: String,
        html: String,
        sections: all(match(a_graphql_object_with(byte_start: Integer, byte_end: Integer, name: String, date_start: String, date_end: String, content: String)))
      )
    )
  end

  context 'we only request the tail' do
    let(:trace_fields) { 'raw(tail: 2) html(tail: 2)' }

    it 'only returns the tail of that length' do
      post_graphql(query, current_user: current_user, variables: variables)

      expect(trace_data['raw'].lines.count).to eq(2)
      expect(trace_data['html']).to match(/after-script.*Job succeeded/)
    end
  end

  it 'has valid sections' do
    post_graphql(query, current_user: current_user, variables: variables)

    sections = trace_data['sections']

    expect(sections.map { |s| s['name'] }).to eq %w(
      prepare_script
      get_sources
      restore_cache
      download_artifacts
      build_script
      after_script
      archive_cache
      upload_artifacts
    )

    %w(byteStart byteEnd dateStart dateEnd).each do |k|
      vals = sections.map { |s| s[k] }

      expect(vals).to eq(vals.sort)
    end

    %w(byte date).each do |prefix|
      sections.each do |s|
        expect(s[prefix + 'Start']).to be <= s[prefix + 'End']
      end
    end

    expect(sections[4]).to match(
      a_graphql_object_with(name: 'build_script', content: "\e[32;1m$ whoami\e[0;m\nroot\n")
    )
  end
end
