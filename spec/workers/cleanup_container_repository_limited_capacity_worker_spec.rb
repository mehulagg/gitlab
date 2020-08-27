# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CleanupContainerRepositoryLimitedCapacityWorker, :clean_gitlab_redis_shared_state do
  let_it_be(:repository) { create(:container_repository) }
  let_it_be(:project) { repository.project }
  let_it_be(:policy) { project.container_expiration_policy }
  let_it_be(:repository_id) { repository.id.to_s }
  let_it_be(:other_repository_ids) { create_list(:container_repository, 5).map(&:id).map(&:to_s) }
  let_it_be(:repository_ids) { ([repository.id] + other_repository_ids).map(&:to_s) }

  let(:worker) { described_class.new }
  let(:redis_key) { CleanupContainerRepositoryLimitedCapacityWorker::CONTAINER_REPOSITORY_IDS_QUEUE }

  describe '#perform_work' do
    subject { worker.perform_work }

    context 'with container repository ids enqueued' do
      before do
        enqueue_repository_ids
      end

      context 'with a successful cleanup tags service execution' do
        let_it_be(:service_params) { project.container_expiration_policy.policy_params.merge(container_expiration_policy: true) }

        let(:service) { double }

        it 'calls it with the proper parameters' do
          expect(Projects::ContainerRepository::CleanupTagsService)
            .to receive(:new).with(project, nil, service_params).and_return(service)
          expect(service).to receive(:execute).with(repository).and_return(status: :success)
          expect { subject }.to change { ids_queue }.from(repository_ids).to(other_repository_ids)
        end
      end

      context 'without a successful cleanup tags service execution' do
        it 're enqueues the repository id' do
          expect(Projects::ContainerRepository::CleanupTagsService)
            .to receive(:new).and_return(double(execute: { status: :error, message: 'timeout' }))
          expect { subject }.to change { ids_queue }.from(repository_ids).to(other_repository_ids + [repository_id])
        end
      end
    end

    context 'with no container repository ids enqueued' do
      it 'does not execute the cleanup tags service' do
        expect(Projects::ContainerRepository::CleanupTagsService).not_to receive(:new)

        expect { subject }.not_to change { ids_queue }
      end
    end

    context 'with invalid container repository ids enqueued' do
      before do
        enqueue_repository_ids([555])
      end

      it 'does not execute the cleanup tags service' do
        expect(Projects::ContainerRepository::CleanupTagsService).not_to receive(:new)

        expect { subject }.to change { ids_queue }.from(%w[555]).to([])
      end
    end
  end

  describe '#remaining_work_count' do
    subject { worker.remaining_work_count }

    context 'with container repository ids enqueued' do
      before do
        enqueue_repository_ids
      end

      it { is_expected.to eq(repository_ids.size) }
    end

    context 'with no container repository ids enqueued' do
      it { is_expected.to eq(0) }
    end
  end

  describe '#max_running_jobs' do
    let(:capacity) { 50 }

    subject { worker.max_running_jobs }

    before do
      stub_application_setting(container_registry_expiration_policies_worker_capacity: capacity)
    end

    it { is_expected.to eq(capacity) }
  end

  def enqueue_repository_ids(ids = repository_ids)
    Sidekiq.redis { |r| r.lpush(redis_key, ids.reverse) }
  end

  def ids_queue
    Sidekiq.redis { |r| r.lrange(redis_key, 0, 10) }
  end
end
