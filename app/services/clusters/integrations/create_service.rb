# frozen_string_literal: true

module Clusters
  module Integrations
    class CreateService < BaseContainerService
      InvalidApplicationError = Class.new(StandardError)

      attr_accessor :cluster

      def initialize(container:, cluster:, current_user: nil, params: {})
        @cluster = cluster

        super(container: container, current_user: current_user, params: params)
      end

      def execute
        #TODO
        # authorize current_user

        instantiate_application.tap do |application|
          if params[:enabled]
            application.make_externally_installed!
          end
        end
      end

      private

      def application_name
        params[:application_type]
      end

      def application_class
        Clusters::Cluster::APPLICATIONS[application_name]
      end

      def instantiate_application
        case application_class&.name
        when Clusters::Applications::Prometheus.name
          cluster.application_prometheus || cluster.build_application_prometheus
        else
          raise(InvalidApplicationError, "invalid application: #{application_name}")
        end
      end
    end
  end
end
