# frozen_string_literal: true

module Clusters
  class Group < NamespaceShard
    self.table_name = 'cluster_groups'

    belongs_to :cluster, class_name: 'Clusters::Cluster'
    belongs_to :group, class_name: '::Group'
  end
end
