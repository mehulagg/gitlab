# frozen_string_literal: true

module Ci
  class PlayBridgeService < ::BaseService
    def execute(bridge)
      raise Gitlab::Access::AccessDeniedError unless bridge.can_run_by?(current_user)

      bridge.enqueue!
      bridge.tap { |action| action.update!(user: current_user) }
    end
  end
end
