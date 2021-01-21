# frozen_string_literal: true

module EE
  module ClusterablePresenter
    def metrics_cluster_path(cluster, params = {})
      raise NotImplementedError
    end
  end
end
