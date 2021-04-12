# frozen_string_literal: true

module Clusters
  module Integrations
    class Prometheus < ApplicationRecord
      self.table_name = 'clusters_integration_prometheus'

      belongs_to :cluster, class_name: 'Clusters::Cluster', foreign_key: :cluster_id

      validates :cluster, presence: true
      validates :enabled, inclusion: { in: [true, false] }
    end
  end
end
