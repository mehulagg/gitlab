# frozen_string_literal: true

module Gitlab
  module Kubernetes
    # Calculates the rollout status for a set of kubernetes deployments.
    #
    # A GitLab environment may be composed of several Kubernetes deployments and
    # other resources. The rollout status sums the Kubernetes deployments
    # together.
    class RolloutStatus
      attr_reader :deployments, :instances, :completion, :status

      def complete?
        completion == 100
      end

      def loading?
        @status == :loading
      end

      def not_found?
        @status == :not_found
      end

      def has_legacy_app_label?
        legacy_deployments.present?
      end

      def found?
        @status == :found
      end

      def self.from_deployments(*deployments_attrs, pods_attrs: {}, legacy_deployments: [])
        return new([], status: :not_found, legacy_deployments: legacy_deployments) if deployments_attrs.empty?

        deployments = deployments_attrs.map do |attrs|
          ::Gitlab::Kubernetes::Deployment.new(attrs, pods: pods_attrs, default_track_value: ::Gitlab::Kubernetes::Deployment::STABLE_TRACK_VALUE)
        end
        deployments.sort_by!(&:order)

        pods = pods_attrs.map do |attrs|
          ::Gitlab::Kubernetes::Pod.new(attrs, default_track_value: ::Gitlab::Kubernetes::Pod::STABLE_TRACK_VALUE)
        end

        rollout_status_pods = create_rollout_status_pods(deployments, pods)

        new(deployments, pods: rollout_status_pods, legacy_deployments: legacy_deployments)
      end

      def self.loading
        new([], status: :loading)
      end

      def initialize(deployments, pods: [], status: :found, legacy_deployments: [])
        @status       = status
        @deployments  = deployments
        @instances    = pods
        @legacy_deployments = legacy_deployments

        @completion =
          if @instances.empty?
            100
          else
            # We downcase the pod status in Gitlab::Kubernetes::Deployment#deployment_instance
            finished = @instances.count { |instance| instance[:status] == ::Gitlab::Kubernetes::Pod::RUNNING.downcase }

            (finished / @instances.count.to_f * 100).to_i
          end
      end

      private

      attr_reader :legacy_deployments

      def self.create_rollout_status_pods(deployments, pods)
        deployment_tracks = deployments.map(&:track)
        filtered_pods = pods.select { |p| deployment_tracks.include?(p.track) }

        wanted_instances = sum_hashes(deployments.map { |d| { d.track => d.wanted_instances } })
        present_instances = sum_hashes(filtered_pods.map { |p| { p.track => 1 } })
        pending_instances = subtract_hashes(wanted_instances, present_instances)

        pending_pods = pending_instances.flat_map do |track, num|
          Array.new(num, pending_pod_for(track))
        end
        total_pods = filtered_pods + pending_pods

        total_pods.sort_by(&:order).map(&:to_hash)
      end

      def self.sum_hashes(hashes)
        hashes.reduce({}) do |memo, hash|
          memo.merge(hash) { |_key, memo_val, hash_val| memo_val + hash_val }
        end
      end

      def self.subtract_hashes(hash_a, hash_b)
        hash_a.merge(hash_b) { |_key, hash_a_val, hash_b_val| [0, hash_a_val - hash_b_val].max }
      end

      def self.pending_pod_for(track)
        ::Gitlab::Kubernetes::Pod.new({
          'status' => { 'phase' => 'Pending' },
          'metadata' => {
            'name' => 'Not provided',
            'labels' => {
              'track' => track
            }
          }

        })
      end
    end
  end
end
