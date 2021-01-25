# frozen_string_literal: true

module Environments
  class BatchDeleteService < ::BaseService
    include ::Gitlab::ExclusiveLeaseHelpers

    EXCLUSIVE_LOCK_KEY_BASE = 'environments:batch_delete:lock'
    LOCK_TIMEOUT = 2.minutes

    def execute
      in_lock(key, ttl: LOCK_TIMEOUT, retries: 1) do
        delete_in_batch
      end
    end

    private

    def key
      "#{EXCLUSIVE_LOCK_KEY_BASE}:#{project.id}"
    end

    def delete_in_batch
      result = Result.new
      environments = Environment.deleteable_review_envs(project, params[:before], params[:limit])

      environments.find_each do |env|
        if current_user.can?(:destroy_environment, env) && (params[:dry_run] || env.destroy)
          result.deleted << env
        else
          result.failed << env
        end
      end

      result
    end

    class Result
      def deleted
        @deleted ||= []
      end

      def failed
        @failed ||= []
      end

      def success?
        deleted.any? && failed.empty?
      end
    end
  end
end
