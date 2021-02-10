# frozen_string_literal: true

module Clusters
  class DeploymentEntity < Grape::Entity
    expose :id, :iid

    expose :deployable do |deployment|
      { name: deployment.deployable.name }
    end
  end
end
