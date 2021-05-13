# frozen_string_literal: true

class DeploymentCluster < NamespaceShard
  belongs_to :deployment, optional: false
  belongs_to :cluster, optional: false, class_name: 'Clusters::Cluster'
end
