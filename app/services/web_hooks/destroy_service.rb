# frozen_string_literal: true

module WebHooks
  class DestroyService
    BATCH_SIZE = 1000
    DestroyError = Class.new(StandardError)

    attr_accessor :current_user, :web_hook

    def initialize(current_user)
      @current_user = current_user
    end

    def execute(web_hook)
      @web_hook = web_hook

      check_permissions!

      destroy_web_hook_logs!
      web_hook.destroy
    end

    private

    def destroy_web_hook_logs!
      loop do
        count = destroy_batch!
        break if count <= 0
      end
    end

    # rubocop: disable CodeReuse/ActiveRecord
    def destroy_batch!
      # We can't use EachBatch because that does an ORDER BY id, which can
      # easily time out. We don't actually care about ordering when
      # we are deleting these rows.
      WebHookLog.delete(WebHookLog.where(web_hook: web_hook).limit(BATCH_SIZE))
    end
    # rubocop: enable CodeReuse/ActiveRecord

    def check_permissions!
      case web_hook
      when ProjectHook
        access_denied! unless Ability.allowed?(current_user, :admin_project, web_hook.project)
      when SystemHook
        access_denied! unless current_user.admin?
      else
        # Group Hook (EE) and ServiceHook not implemented yet
        access_denied!
      end
    end

    def access_denied!
      raise Gitlab::Access::AccessDeniedError, "User #{current_user.username} (#{current_user.id}) tried to destroy hook #{web_hook.id}!"
    end
  end
end
