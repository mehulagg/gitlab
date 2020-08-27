# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ContainerExpirationPolicyWorker, :clean_gitlab_redis_shared_state do
  let(:worker) { described_class.new }
  let(:started_at) { nil }

  describe '#perform' do
    subject { worker.perform }

    context 'with throttling enabled' do
      let(:redis_key) { CleanupContainerRepositoryLimitedCapacityWorker::CONTAINER_REPOSITORY_IDS_QUEUE }

      before do
        stub_feature_flags(container_registry_expiration_policies_throttling: true)
      end

      context 'With no container expiration policies' do
        it 'does not execute any policies' do
          expect(CleanupContainerRepositoryLimitedCapacityWorker).not_to receive(:perform_with_capacity)

          expect { subject }.not_to change { redis_queue_size }
        end
      end

      context 'with container expiration policies' do
        let_it_be(:container_expiration_policy) { create(:container_expiration_policy, :runnable) }
        let_it_be(:container_repository) { create(:container_repository, project: container_expiration_policy.project) }

        context 'with a valid container expiration policy' do
          it 'schedules the next run' do
            expect { subject }.to change { container_expiration_policy.reload.next_run_at }
          end

          it 'enqueues container repository ids in redis' do
            expect(Sidekiq).to receive(:redis).at_least(:once).and_call_original
            expect { subject }
              .to change { redis_queue_size }.from(0).to(1)
            expect(redis_queue_head).to eq(container_repository.id.to_s)
          end

          it 'calls the limited capacity worker' do
            expect(CleanupContainerRepositoryLimitedCapacityWorker).to receive(:perform_with_capacity)

            subject
          end
        end

        context 'with a disabled container expiration policy' do
          before do
            container_expiration_policy.disable!
          end

          it 'does not run the policy' do
            expect(CleanupContainerRepositoryLimitedCapacityWorker).not_to receive(:perform_with_capacity)

            expect { subject }.not_to change { redis_queue_size }
          end
        end

        context 'with an invalid container expiration policy' do
          let(:user) { container_expiration_policy.project.owner }

          before do
            container_expiration_policy.update_column(:name_regex, '*production')
          end

          it 'disables the policy and tracks an error' do
            expect(worker).not_to receive(:enqueue_in_redis)
            expect(CleanupContainerRepositoryLimitedCapacityWorker).not_to receive(:perform_with_capacity)
            expect(Gitlab::ErrorTracking).to receive(:log_exception).with(instance_of(described_class::InvalidPolicyError), container_expiration_policy_id: container_expiration_policy.id)

            expect { subject }.to change { container_expiration_policy.reload.enabled }.from(true).to(false)
          end
        end
      end

      def redis_queue_size
        Sidekiq.redis { |r| r.llen(redis_key) }
      end

      def redis_queue_head
        Sidekiq.redis { |r| r.lpop(redis_key) }
      end
    end

    context 'with throttling disabled' do
      before do
        stub_feature_flags(container_registry_expiration_policies_throttling: false)
      end

      context 'with no container expiration policies' do
        it 'does not execute any policies' do
          expect(ContainerExpirationPolicyService).not_to receive(:new)

          subject
        end
      end

      context 'with container expiration policies' do
        let(:user) { container_expiration_policy.project.owner }

        context 'a valid policy' do
          let_it_be(:container_expiration_policy) { create(:container_expiration_policy, :runnable) }

          it 'runs the policy' do
            service = instance_double(ContainerExpirationPolicyService, execute: true)

            expect(ContainerExpirationPolicyService)
              .to receive(:new).with(container_expiration_policy.project, user).and_return(service)

            subject
          end
        end

        context 'a disabled policy' do
          let_it_be(:container_expiration_policy) { create(:container_expiration_policy, :runnable, :disabled) }

          it 'does not run the policy' do
            expect(ContainerExpirationPolicyService)
              .not_to receive(:new).with(container_expiration_policy, user)

            subject
          end
        end

        context 'a policy that is not due for a run' do
          let_it_be(:container_expiration_policy) { create(:container_expiration_policy) }
          let(:user) {container_expiration_policy.project.owner }

          it 'does not run the policy' do
            expect(ContainerExpirationPolicyService)
              .not_to receive(:new).with(container_expiration_policy, user)

            subject
          end
        end

        context 'an invalid policy' do
          let_it_be(:container_expiration_policy) { create(:container_expiration_policy, :runnable) }
          let_it_be(:user) {container_expiration_policy.project.owner }

          before do
            container_expiration_policy.update_column(:name_regex, '*production')
          end

          it 'disables the policy and tracks an error' do
            expect(ContainerExpirationPolicyService).not_to receive(:new).with(container_expiration_policy, user)
            expect(Gitlab::ErrorTracking).to receive(:log_exception).with(instance_of(described_class::InvalidPolicyError), container_expiration_policy_id: container_expiration_policy.id)

            expect { subject }.to change { container_expiration_policy.reload.enabled }.from(true).to(false)
          end
        end
      end
    end
  end
end
