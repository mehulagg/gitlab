# frozen_string_literal: true

module Ci
  module ResetAvailableMinutesService
    def initialize(namespace)
      @namespace = namespace
    end

    def execute
      return unless namespace

      reset_ci_minutes!
      update_pending_builds!

    rescue StandardError => e
      Gitlab::ErrorTracking.track_exception(
        e,
        namespace_id: namespace.id
      )
    end

    private

    attr_reader :namespace

    def reset_ci_minutes!
      ::Gitlab::Ci::Minutes::CachedQuota.new(namespace).expire!
    end

    def update_pending_builds!
      minutes_exceeded = namespace.ci_minutes_quota.minutes_used_up?

      Ci::PendingBuild.transaction do
        Ci::PendingBuild.with_namespace(namespace).update_all(minutes_exceeded: minutes_exceeded)
      end
    end
  end
end
