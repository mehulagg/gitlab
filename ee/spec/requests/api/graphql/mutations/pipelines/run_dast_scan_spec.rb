# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Running a DAST Scan' do
  include GraphqlHelpers

  let(:project) { create(:project, :repository, creator: current_user) }
  let(:current_user) { create(:user) }
  let(:project_path) { project.full_path }
  let(:target_url) { generate(:url) }
  let(:branch) { project.default_branch }
  let(:scan_type) { Types::DastScanTypeEnum.enum[:passive].upcase }

  let(:mutation) do
    graphql_mutation(
      :run_dast_scan,
      branch: branch,
      project_path: project_path,
      target_url: target_url,
      scan_type: scan_type
    )
  end

  def mutation_response
    graphql_mutation_response(:run_dast_scan)
  end

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  context 'when on demand scan feature is not enabled' do
    it_behaves_like 'a mutation that returns top-level errors',
                    errors: ['The resource that you are attempting to access does not ' \
                             'exist or you don\'t have permission to perform this action']
  end

  context 'when on demand scan feature is enabled' do
    context 'when the user does not have permission to run a dast scan' do
      it_behaves_like 'a mutation that returns top-level errors',
                      errors: ['The resource that you are attempting to access does not ' \
                               'exist or you don\'t have permission to perform this action']
    end

    context 'when the user can run a dast scan' do
      before do
        project.add_developer(current_user)
      end

      it 'returns a pipeline_url containing the correct path' do
        post_graphql_mutation(mutation, current_user: current_user)
        pipeline = Ci::Pipeline.last
        expected_url = Rails.application.routes.url_helpers.project_pipeline_url(
          project,
          pipeline
        )
        expect(mutation_response['pipelineUrl']).to eq(expected_url)
      end

      context 'when pipeline creation fails' do
        before do
          allow_any_instance_of(Ci::Pipeline).to receive(:created_successfully?).and_return(false)
          allow_any_instance_of(Ci::Pipeline).to receive(:full_error_messages).and_return('error message')
        end

        it_behaves_like 'a mutation that returns errors in the response', errors: ['error message']
      end
    end
  end
end
