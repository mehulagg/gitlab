# frozen_string_literal: true

module Environments
  class DeleteReviewAppsService < ::BaseService
    include ::Gitlab::ExclusiveLeaseHelpers

    EXCLUSIVE_LOCK_KEY_BASE = 'environments:delete_review_apps:lock'
    LOCK_TIMEOUT = 2.minutes

    def execute
      in_lock(key, ttl: LOCK_TIMEOUT, retries: 1) do
        mark_deletable_environments
      end

    rescue FailedToObtainLockError => ex
      Result.new(error_message: "Another process is already processing a delete request. Please retry later.", status: 409)
    end

    private

    def key
      "#{EXCLUSIVE_LOCK_KEY_BASE}:#{project.id}"
    end

    def mark_deletable_environments
      result = Result.new
      environments = Environment.stopped_review_apps(project, params[:before], params[:limit])

      result.deletable, result.failed = *environments.partition { |env| current_user.can?(:destroy_environment, env) }

      if result.deletable.any? && !params[:dry_run]
        mark_for_deletion(result.deletable)
      end

      result
    end

    def mark_for_deletion(deletable_environments)
      Environment.where(id: deletable_environments).update_all(auto_delete_at: 1.week.from_now)
    end

    class Result
      attr_accessor :deletable, :failed, :error_message, :status

      def initialize(deletable: [], failed: [], error_message: nil)
        self.deletable = deletable
        self.failed = failed
        self.error_message = error_message
      end

      def success?
        deletable.any? && failed.empty?
      end

      def error_message
        @error_message ||= set_error_message
      end

      def status
        @status ||= set_status
      end

      private

      def set_error_message
        unless success?
          "Failed to authorize deletions for some or all of the supplied environments."
        end
      end

      def set_status
        success? ? 200 : 400
      end
    end
  end
end
