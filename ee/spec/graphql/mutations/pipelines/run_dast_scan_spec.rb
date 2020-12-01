# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Pipelines::RunDastScan do
  let(:group) { create(:group) }
  let(:project) { create(:project, :repository, group: group) }
  let(:user) { create(:user) }
  let(:project_path) { project.full_path }
  let(:target_url) { generate(:url) }
  let(:branch) { project.default_branch }
  let(:scan_type) { Types::DastScanTypeEnum.enum[:passive] }

  subject(:mutation) { described_class.new(object: nil, context: { current_user: user }, field: nil) }

  before do
    stub_licensed_features(security_on_demand_scans: true)
  end

  describe '#resolve' do
    subject do
      mutation.resolve(
        branch: branch,
        project_path: project_path,
        target_url: target_url,
        scan_type: scan_type
      )
    end

    context 'when on demand scan feature is not enabled' do
      it 'raises an exception' do
        expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
      end
    end

    context 'when on demand scan feature is enabled' do
      context 'when the project does not exist' do
        let(:project_path) { SecureRandom.hex }

        it 'raises an exception' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the user is not associated with the project' do
        it 'raises an exception' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the user is an owner' do
        it 'has no errors' do
          group.add_owner(user)

          expect(subject[:errors]).to be_empty
        end
      end

      context 'when the user is a maintainer' do
        it 'has no errors' do
          project.add_maintainer(user)

          expect(subject[:errors]).to be_empty
        end
      end

      context 'when the user is a developer' do
        it 'has no errors' do
          project.add_developer(user)

          expect(subject[:errors]).to be_empty
        end
      end

      context 'when the user can run a dast scan' do
        it 'returns a pipeline_url containing the correct path' do
          project.add_developer(user)

          actual_url = subject[:pipeline_url]
          pipeline = Ci::Pipeline.last
          expected_url = Rails.application.routes.url_helpers.project_pipeline_url(
            project,
            pipeline
          )
          expect(actual_url).to eq(expected_url)
        end
      end
    end
  end
end
