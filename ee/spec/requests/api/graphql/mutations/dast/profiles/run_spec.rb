# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Running a DAST Profile' do
  include GraphqlHelpers

  let!(:dast_profile) { create(:dast_profile, project: project) }

  let(:mutation_name) { :dast_profile_run }

  let(:mutation) do
    graphql_mutation(
      mutation_name,
      full_path: project.full_path,
      id: global_id_of(dast_profile)
    )
  end

  it_behaves_like 'an on-demand scan mutation when user cannot run an on-demand scan'

  it_behaves_like 'an on-demand scan mutation when user can run an on-demand scan' do
    it 'returns a pipeline_url containing the correct path' do
      post_graphql_mutation(mutation, current_user: current_user)
      pipeline = Ci::Pipeline.last
      expected_url = Gitlab::Routing.url_helpers.project_pipeline_url(
        project,
        pipeline
      )

      expect(mutation_response['pipelineUrl']).to eq(expected_url)
    end

    context 'when pipeline creation fails' do
      before do
        allow_next_instance_of(Ci::Pipeline) do |instance|
          allow(instance).to receive(:created_successfully?).and_return(false)
          allow(instance).to receive(:full_error_messages).and_return('error message')
        end
      end

      it_behaves_like 'a mutation that returns errors in the response', errors: ['error message']
    end
  end
end
