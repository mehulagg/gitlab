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

      def self.from_deployments(*deployments_attrs, pods_attrs: [], legacy_deployments: [])
        return new([], status: :not_found, legacy_deployments: legacy_deployments) if deployments_attrs.empty?

        deployments = deployments_attrs.map do |attrs|
          ::Gitlab::Kubernetes::Deployment.new(attrs, pods: pods_attrs, default_track_value: ::Gitlab::Kubernetes::Deployment::STABLE_TRACK_VALUE)
        end
        deployments.sort_by!(&:order)

        new(deployments, pods_attrs: pods_attrs, legacy_deployments: legacy_deployments)
      end

      def self.loading
        new([], status: :loading)
      end

      def initialize(deployments, pods_attrs: [], status: :found, legacy_deployments: [])
        @status       = status
        @deployments  = deployments
        @legacy_deployments = legacy_deployments

        pods = pods_attrs.map do |attrs|
          ::Gitlab::Kubernetes::Pod.new(attrs, default_track_value: ::Gitlab::Kubernetes::Pod::STABLE_TRACK_VALUE)
        end

        matching_pods = take_pods_matching_any_deployment_track(deployments, pods)
        extra_pending_pods = create_inferred_pending_pods(deployments, matching_pods)
        rollout_status_pods = matching_pods + extra_pending_pods
        @instances = rollout_status_pods.sort_by(&:order).map do |pod|
          to_hash(pod)
        end

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

      def take_pods_matching_any_deployment_track(deployments, pods)
        deployment_tracks = deployments.map(&:track)
        pods.select { |p| deployment_tracks.include?(p.track) }
      end

      def create_inferred_pending_pods(deployments, pods_matching_deployment_tracks)
        wanted_instances = sum_hashes(deployments.map { |d| { d.track => d.wanted_instances } })
        present_instances = sum_hashes(pods_matching_deployment_tracks.map { |p| { p.track => 1 } })
        pending_instances = subtract_hashes(wanted_instances, present_instances)

        pending_instances.flat_map do |track, num|
          Array.new(num, pending_pod_for(track))
        end
      end

      def sum_hashes(hashes)
        hashes.reduce({}) do |memo, hash|
          memo.merge(hash) { |_key, memo_val, hash_val| memo_val + hash_val }
        end
      end

      def subtract_hashes(hash_a, hash_b)
        hash_a.merge(hash_b) { |_key, hash_a_val, hash_b_val| [0, hash_a_val - hash_b_val].max }
      end

      def pending_pod_for(track)
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

      def to_hash(pod)
        {
          status: pod.status&.downcase,
          pod_name: pod.name,
          tooltip: "#{pod.name} (#{pod.status})",
          track: pod.track,
          stable: pod.stable?
        }
      end
    end
  end
end
