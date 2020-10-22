# frozen_string_literal: true

module EE
  module Clusters
    module InstancePolicy
      extend ActiveSupport::Concern

      prepended do
        with_scope :global
        condition(:cluster_deployments_available) do
          License.feature_available?(:cluster_deployments)
        end

        rule { can?(:read_cluster) & cluster_deployments_available }
          .enable :read_cluster_environments
      end
    end
  end
end
