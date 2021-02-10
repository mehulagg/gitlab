# frozen_string_literal: true

module Clusters
  class EnvironmentSerializer < BaseSerializer
    include WithPagination

    entity ::Clusters::EnvironmentEntity
  end
end
