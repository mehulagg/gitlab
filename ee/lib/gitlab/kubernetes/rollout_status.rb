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

      def self.from_deployments(*deployments, pods_attrs: {})
        return new([], status: :not_found) if deployments.empty?

        deployments = deployments.map { |deploy| ::Gitlab::Kubernetes::Deployment.new(deploy, pods: pods_attrs) }
        deployments.sort_by!(&:order)
        new(deployments)
      end

      def self.loading
        new([], status: :loading)
      end

      def initialize(deployments, status: :found)
        @status       = status
        @deployments  = deployments
        @instances    = deployments.flat_map(&:instances)

        @completion =
          if @instances.empty?
            100
          else
            # We downcase the pod status in Gitlab::Kubernetes::Deployment#deployment_instance
            finished = @instances.count { |instance| instance[:status] == Gitlab::Kubernetes::Pod::RUNNING.downcase }

            (finished / @instances.count.to_f * 100).to_i
          end
      end
    end
  end
end
