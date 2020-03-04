# frozen_string_literal: true

require 'spec_helper'

describe Clusters::Management::ApplyApplicationConfigurationService do
  let(:user) { create(:user) }
  let(:management_project) { create(:project) }
  let(:last_seen_ref) { 'current-ref' }
  let(:cluster) { create(:cluster, management_project: management_project) }

  subject { described_class.new(cluster, current_user: user, last_seen_ref: last_seen_ref).execute }

  shared_examples 'configuration is applied' do
    let(:repository) { create(:project_repository) }
    let(:management_project) { repository.project }
    let(:result) { { status: :success } }
    let(:commit_params) do
      {
        file_path: described_class::CONFIGURATION_FILE_PATH,
        commit_message: _('Update cluster management project'),
        file_content: new_configuration.to_yaml,
        branch_name: management_project.default_branch,
        start_branch: management_project.default_branch
      }
    end

    before do
      create(:clusters_applications_ingress, :installing, :no_helm_installed, cluster: cluster)
    end

    it 'calls the appropriate file management service to create a commit' do
      expect(management_project.repository).to receive(:blob_at)
        .with(management_project.default_branch, described_class::CONFIGURATION_FILE_PATH)
        .and_return(blob)

      expect(file_service).to receive(:new)
        .with(management_project, user, commit_params)
        .and_return(double(execute: result))

      expect(subject).to eq result
    end
  end

  context 'config file is not present' do
    let(:file_service) { Files::CreateService }
    let(:blob) { }
    let(:new_configuration) do
      {
        'ingress'      => { 'installed' => true },
        'certManager'  => { 'installed' => false },
        'crossplane'   => { 'installed' => false },
        'prometheus'   => { 'installed' => false },
        'gitlabRunner' => { 'installed' => false },
        'jupyter'      => { 'installed' => false },
        'elasticStack' => { 'installed' => false }
      }
    end

    include_examples 'configuration is applied'
  end

  context 'config file is present' do
    let(:file_service) { Files::UpdateService }
    let(:blob) { double(data: existing_configuration.to_yaml)}
    let(:existing_configuration) do
      {
        'sentry' => {
          'installed' => true
        }
      }
    end

    let(:new_configuration) do
      existing_configuration.merge(
        {
          'ingress'      => { 'installed' => true },
          'certManager'  => { 'installed' => false },
          'crossplane'   => { 'installed' => false },
          'prometheus'   => { 'installed' => false },
          'gitlabRunner' => { 'installed' => false },
          'jupyter'      => { 'installed' => false },
          'elasticStack' => { 'installed' => false }
        }
      )
    end

    include_examples 'configuration is applied'
  end

  shared_examples 'configuration is not applied' do
    it 'does not call commit services' do
      expect(Files::UpdateService).not_to receive(:new)
      expect(Files::CreateService).not_to receive(:new)

      expect(subject).to eq({
        status: :error,
        message: error_message
      })
    end
  end

  context 'feature flag is disabled' do
    let(:error_message) { 'Cluster management project not configured' }

    before do
      stub_feature_flags(ci_managed_cluster_applications: false)
    end

    include_examples 'configuration is not applied'
  end

  context 'management project is not present' do
    let(:management_project) { nil }
    let(:error_message) { 'Cluster management project not configured' }

    include_examples 'configuration is not applied'
  end

  context 'config file contains invalid yaml' do
    let(:repository) { create(:project_repository) }
    let(:management_project) { repository.project }
    let(:blob) { double(data: '`') }

    let(:error_message) { 'Invalid configuration file' }

    before do
      allow(management_project.repository).to receive(:blob_at)
        .with(management_project.default_branch, described_class::CONFIGURATION_FILE_PATH)
        .and_return(blob)
    end

    include_examples 'configuration is not applied'
  end

  context 'last seen ref does not match the management project' do
    let(:error_message) { 'Last seen ref does not match cluster management project' }

    before do
      allow(management_project).to receive(:commit)
        .with(management_project.default_branch)
        .and_return('other-ref')
    end

    include_examples 'configuration is not applied'
  end
end
