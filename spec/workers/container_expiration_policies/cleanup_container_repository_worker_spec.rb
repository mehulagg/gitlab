# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContainerExpirationPolicies::CleanupContainerRepositoryWorker do
  using RSpec::Parameterized::TableSyntax

  let_it_be(:repository, reload: true) { create(:container_repository, :cleanup_scheduled) }
  let_it_be(:project) { repository.project }
  let_it_be(:policy) { project.container_expiration_policy }
  let_it_be(:other_repository) { create(:container_repository) }

  let(:worker) { described_class.new }

  describe '#perform_work' do
    subject { worker.perform_work }

    before do
      policy.update_column(:enabled, true)
    end

    RSpec.shared_examples 'handling all repository conditions' do
      it 'sends the repository for cleaning' do
        service_response = cleanup_service_response(repository: repository)
        expect(ContainerExpirationPolicies::CleanupService)
          .to receive(:new).with(repository).and_return(double(execute: service_response))
        expect_log_extra_metadata(service_response: service_response)

        subject
      end

      context 'with unfinished cleanup' do
        it 'logs an unfinished cleanup' do
          service_response = cleanup_service_response(status: :unfinished, repository: repository)
          expect(ContainerExpirationPolicies::CleanupService)
            .to receive(:new).with(repository).and_return(double(execute: service_response))
          expect_log_extra_metadata(service_response: service_response, cleanup_status: :unfinished)

          subject
        end

        context 'with a truncated list of tags to delete' do
          it 'logs an unfinished cleanup' do
            service_response = cleanup_service_response(status: :unfinished, repository: repository, cleanup_tags_service_after_truncate_size: 10, cleanup_tags_service_before_delete_size: 5)
            expect(ContainerExpirationPolicies::CleanupService)
              .to receive(:new).with(repository).and_return(double(execute: service_response))
            expect_log_extra_metadata(service_response: service_response, cleanup_status: :unfinished, truncated: true)

            subject
          end
        end

        context 'the truncated log field' do
          where(:before_truncate_size, :after_truncate_size, :truncated) do
            100 | 100 | false
            100 | 80  | true
            nil | 100 | false
            100 | nil | false
            nil | nil | false
          end

          with_them do
            it 'is logged properly' do
              service_response = cleanup_service_response(status: :unfinished, repository: repository, cleanup_tags_service_after_truncate_size: after_truncate_size, cleanup_tags_service_before_truncate_size: before_truncate_size)
              expect(ContainerExpirationPolicies::CleanupService)
                .to receive(:new).with(repository).and_return(double(execute: service_response))
              expect_log_extra_metadata(service_response: service_response, cleanup_status: :unfinished, truncated: truncated)

              subject
            end
          end
        end
      end

      context 'with policy running shortly' do
        before do
          repository.project
                    .container_expiration_policy
                    .update_column(:next_run_at, 1.minute.from_now)
        end

        it 'skips the repository' do
          expect(ContainerExpirationPolicies::CleanupService).not_to receive(:new)
          expect(worker).to receive(:log_extra_metadata_on_done).with(:container_repository_id, repository.id)
          expect(worker).to receive(:log_extra_metadata_on_done).with(:cleanup_status, :skipped)

          expect { subject }.to change { ContainerRepository.waiting_for_cleanup.count }.from(1).to(0)
          expect(repository.reload.cleanup_unscheduled?).to be_truthy
        end
      end

      context 'with disabled policy' do
        before do
          repository.project
                    .container_expiration_policy
                    .disable!
        end

        it 'skips the repository' do
          expect(ContainerExpirationPolicies::CleanupService).not_to receive(:new)

          expect { subject }.to change { ContainerRepository.waiting_for_cleanup.count }.from(1).to(0)
          expect(repository.reload.cleanup_unscheduled?).to be_truthy
        end
      end
    end

    context 'with repository in cleanup scheduled state' do
      it_behaves_like 'handling all repository conditions'
    end

    context 'with repository in cleanup unfinished state' do
      before do
        repository.cleanup_unfinished!
      end

      it_behaves_like 'handling all repository conditions'
    end

    context 'with another repository in cleanup unfinished state' do
      let_it_be(:another_repository) { create(:container_repository, :cleanup_unfinished) }

      it 'process the cleanup scheduled repository first' do
        service_response = cleanup_service_response(repository: repository)
        expect(ContainerExpirationPolicies::CleanupService)
          .to receive(:new).with(repository).and_return(double(execute: service_response))
        expect_log_extra_metadata(service_response: service_response)

        subject
      end
    end

    context 'with multiple repositories in cleanup unfinished state' do
      let_it_be(:repository2) { create(:container_repository, :cleanup_unfinished, expiration_policy_started_at: 20.minutes.ago) }
      let_it_be(:repository3) { create(:container_repository, :cleanup_unfinished, expiration_policy_started_at: 10.minutes.ago) }

      before do
        repository.update!(expiration_policy_cleanup_status: :cleanup_unfinished, expiration_policy_started_at: 30.minutes.ago)
      end

      it 'process the repository with the oldest expiration_policy_started_at' do
        service_response = cleanup_service_response(repository: repository)
        expect(ContainerExpirationPolicies::CleanupService)
          .to receive(:new).with(repository).and_return(double(execute: service_response))
        expect_log_extra_metadata(service_response: service_response)

        subject
      end
    end

    context 'with repository in cleanup ongoing state' do
      before do
        repository.cleanup_ongoing!
      end

      it 'does not process it' do
        expect(Projects::ContainerRepository::CleanupTagsService).not_to receive(:new)

        expect { subject }.not_to change { ContainerRepository.waiting_for_cleanup.count }
        expect(repository.cleanup_ongoing?).to be_truthy
      end
    end

    context 'with no repository in any cleanup state' do
      before do
        repository.cleanup_unscheduled!
      end

      it 'does not process it' do
        expect(Projects::ContainerRepository::CleanupTagsService).not_to receive(:new)

        expect { subject }.not_to change { ContainerRepository.waiting_for_cleanup.count }
        expect(repository.cleanup_unscheduled?).to be_truthy
      end
    end

    context 'with no container repository waiting' do
      before do
        repository.destroy!
      end

      it 'does not execute the cleanup tags service' do
        expect(Projects::ContainerRepository::CleanupTagsService).not_to receive(:new)

        expect { subject }.not_to change { ContainerRepository.waiting_for_cleanup.count }
      end
    end

    context 'with feature flag disabled' do
      before do
        stub_feature_flags(container_registry_expiration_policies_throttling: false)
      end

      it 'is a no-op' do
        expect(Projects::ContainerRepository::CleanupTagsService).not_to receive(:new)

        expect { subject }.not_to change { ContainerRepository.waiting_for_cleanup.count }
      end
    end

    def cleanup_service_response(status: :finished, repository:, cleanup_tags_service_original_size: 100, cleanup_tags_service_before_truncate_size: 80, cleanup_tags_service_after_truncate_size: 80, cleanup_tags_service_before_delete_size: 50)
      ServiceResponse.success(
        message: "cleanup #{status}",
        payload: {
          cleanup_status: status,
          container_repository_id: repository.id,
          cleanup_tags_service_original_size: cleanup_tags_service_original_size,
          cleanup_tags_service_before_truncate_size: cleanup_tags_service_before_truncate_size,
          cleanup_tags_service_after_truncate_size: cleanup_tags_service_after_truncate_size,
          cleanup_tags_service_before_delete_size: cleanup_tags_service_before_delete_size
        }.compact
      )
    end

    def expect_log_extra_metadata(service_response:, cleanup_status: :finished, truncated: false)
      expect(worker).to receive(:log_extra_metadata_on_done).with(:cleanup_status, cleanup_status)
      expect(worker).to receive(:log_extra_metadata_on_done).with(:container_repository_id, repository.id)
      %i[cleanup_tags_service_original_size cleanup_tags_service_before_truncate_size cleanup_tags_service_after_truncate_size cleanup_tags_service_before_delete_size].each do |field|
        value = service_response.payload[field]
        expect(worker).to receive(:log_extra_metadata_on_done).with(field, value) unless value.nil?
      end
      expect(worker).to receive(:log_extra_metadata_on_done).with(:cleanup_tags_service_truncated, truncated)
    end
  end

  describe '#remaining_work_count' do
    subject { worker.remaining_work_count }

    context 'with container repositoires waiting for cleanup' do
      let_it_be(:unfinished_repositories) { create_list(:container_repository, 2, :cleanup_unfinished) }

      it { is_expected.to eq(3) }

      it 'logs the work count' do
        expect_log_info(
          cleanup_scheduled_count: 1,
          cleanup_unfinished_count: 2,
          cleanup_total_count: 3
        )

        subject
      end
    end

    context 'with no container repositories waiting for cleanup' do
      before do
        repository.cleanup_ongoing!
      end

      it { is_expected.to eq(0) }

      it 'logs 0 work count' do
        expect_log_info(
          cleanup_scheduled_count: 0,
          cleanup_unfinished_count: 0,
          cleanup_total_count: 0
        )

        subject
      end
    end
  end

  describe '#max_running_jobs' do
    let(:capacity) { 50 }

    subject { worker.max_running_jobs }

    before do
      stub_application_setting(container_registry_expiration_policies_worker_capacity: capacity)
    end

    it { is_expected.to eq(capacity) }

    context 'with feature flag disabled' do
      before do
        stub_feature_flags(container_registry_expiration_policies_throttling: false)
      end

      it { is_expected.to eq(0) }
    end
  end

  def expect_log_info(structure)
    expect(worker.logger)
      .to receive(:info).with(worker.structured_payload(structure))
  end
end
