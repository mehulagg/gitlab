# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'getting pipeline information nested in a project' do
  include GraphqlHelpers

  let!(:project) { create(:project, :repository, :public) }
  let!(:pipeline) { create(:ci_pipeline, project: project) }
  let!(:current_user) { create(:user) }
  let(:pipeline_graphql_data) { graphql_data['project']['pipeline'] }

  let!(:query) do
    graphql_query_for(
      'project',
      { 'fullPath' => project.full_path },
      query_graphql_field('pipeline', iid: pipeline.iid.to_s)
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

  context 'batching' do
    let!(:pipeline2) { create(:ci_pipeline, project: project, user: current_user, builds: [create(:ci_build, :success)]) }
    let!(:pipeline3) { create(:ci_pipeline, project: project, user: current_user, builds: [create(:ci_build, :success)]) }

    let!(:query) do
      graphql_query_for(
        'project',
        { 'fullPath' => project.full_path },
        [
          "pipeline1: #{query_graphql_field('pipeline', iid: pipeline.iid.to_s)}",
          "pipeline2: #{query_graphql_field('pipeline', iid: pipeline2.iid.to_s)}",
          "pipeline3: #{query_graphql_field('pipeline', iid: pipeline3.iid.to_s)}"
        ].join(' ')
      )
    end

    it 'executes the finder once' do
      mock = double(Ci::PipelinesFinder)
      opts = { iids: [pipeline.iid, pipeline2.iid, pipeline3.iid].map(&:to_s) }

      expect(Ci::PipelinesFinder).to receive(:new).once.with(project, current_user, opts).and_return(mock)
      expect(mock).to receive(:execute).once.and_return(Ci::Pipeline.none)

      post_graphql(query, current_user: current_user)
    end

    it 'keeps the queries under the threshold' do
      control = ActiveRecord::QueryRecorder.new { post_graphql(query, current_user: current_user) }

      aggregate_failures do
        expect(control.count).to be <= 91
        expect(response).to have_gitlab_http_status(:success)
      end
    end
  end
end
