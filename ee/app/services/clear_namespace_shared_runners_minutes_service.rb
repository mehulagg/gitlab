# frozen_string_literal: true

class ClearNamespaceSharedRunnersMinutesService < BaseService
  def initialize(namespace)
    @namespace = namespace
  end

  # rubocop: disable CodeReuse/ActiveRecord
  def execute
    NamespaceStatistics.where(namespace: @namespace).update_all(
      shared_runners_seconds: 0,
      shared_runners_seconds_last_reset: Time.current
    )
  end
  # rubocop: enable CodeReuse/ActiveRecord
end
