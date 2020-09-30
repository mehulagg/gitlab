# frozen_string_literal: true

module RolloutStatuses
  class CanaryIngress < Grape::Entity
    expose :weight
  end
end
