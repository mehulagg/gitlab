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

      def found?
        @status == :found
      end

      def self.from_deployments(*deployments_attrs, pods_attrs: [])
        return new([], status: :not_found) if deployments_attrs.empty?

        deployments = deployments_attrs.map do |attrs|
          ::Gitlab::Kubernetes::Deployment.new(attrs, pods: pods_attrs)
        end
        deployments.sort_by!(&:order)

        pods = pods_attrs.map do |attrs|
          ::Gitlab::Kubernetes::Pod.new(attrs)
        end

        new(deployments, pods: pods)
      end

      def self.loading
        new([], status: :loading)
      end

      def initialize(deployments, pods: [], status: :found)
        @status       = status
        @deployments  = deployments

        @instances = if ::Feature.enabled?(:deploy_boards_dedupe_instances)
                       RolloutInstances.new(deployments, pods).pod_instances
                     else
                       deployments.flat_map(&:instances)
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
    end
  end
end
