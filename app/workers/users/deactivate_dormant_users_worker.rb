# frozen_string_literal: true

module Users
  class DeactivateDormantUsersWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include CronjobQueue

    feature_category :utilization

    BATCH_SIZE = 100

    def perform
      return if Gitlab.com?
      return unless ::Gitlab::CurrentSettings.current_application_settings.deactivate_dormant_users

      User.dormant.find_each(batch_size: BATCH_SIZE) { |user| deactivate(user) }

      User.with_no_activity.find_each(batch_size: BATCH_SIZE) { |user| deactivate(user) }
    end

    private

    def deactivate(user)
      if user.can_be_deactivated?
        with_context(user: user) { user.deactivate }
      end
    end
  end
end
