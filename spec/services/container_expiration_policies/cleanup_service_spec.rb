# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContainerExpirationPolicies::CleanupService do
  let_it_be(:repository, reload: true) { create(:container_repository) }
  let_it_be(:project) { repository.project }

  let(:service) { described_class.new(container: repository) }

  describe '#execute' do
    subject { service.execute }

    context 'with a successful cleanup tags service execution' do
      let(:cleanup_tags_service_params) { project.container_expiration_policy.policy_params.merge('container_expiration_policy' => true) }
      let(:cleanup_tags_service) { double }

      it 'completely clean up the repository' do
        expect(Projects::ContainerRepository::CleanupTagsService)
            .to receive(:new).with(project, nil, cleanup_tags_service_params).and_return(cleanup_tags_service)
        expect(cleanup_tags_service).to receive(:execute).with(repository).and_return(status: :success)
        expect_log_info(cleanup_status: :starting)
        expect_log_info(cleanup_status: :service_execution_done, service_result_status: :success, service_result_message: nil)
        expect_log_info(cleanup_status: :finished)

        expect(subject).to include(status: :success, cleanup_status: :finished)
        expect(ContainerRepository.waiting_for_cleanup.count).to eq(0)
        expect(repository.reload.expiration_policy_cleanup_status).to eq(nil)
        expect(repository.expiration_policy_started_at).to eq(nil)
      end
    end

    context 'without a successful cleanup tags service execution' do
      it 'partially clean up the repository' do
        expect(Projects::ContainerRepository::CleanupTagsService)
            .to receive(:new).and_return(double(execute: { status: :error, message: 'timeout' }))
        expect_log_info(cleanup_status: :starting)
        expect_log_info(cleanup_status: :service_execution_done, service_result_status: :error, service_result_message: 'timeout')
        expect_log_info(cleanup_status: :unfinished)

        expect(subject).to include(status: :success, cleanup_status: :unfinished)
        expect(ContainerRepository.waiting_for_cleanup.count).to eq(1)
        expect(repository.reload.cleanup_unfinished?).to be_truthy
        expect(repository.expiration_policy_started_at).not_to eq(nil)
      end
    end

    context 'with no repository' do
      let(:service) { described_class.new(container: nil) }

      it { is_expected.to include(status: :error) }
    end
  end

  def expect_log_info(structure)
    expect(Gitlab::AppLogger)
    .to receive(:info).with({ service_class: described_class.to_s, container_repository_id: repository.id }.merge(structure))
  end
end
