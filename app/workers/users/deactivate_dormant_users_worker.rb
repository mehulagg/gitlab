# frozen_string_literal: true

module Users
  class DeactivateDormantUsersWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include CronjobQueue

    feature_category :utilization

    def perform
      return if Gitlab.com?
      return unless ::Gitlab::CurrentSettings.current_application_settings.deactivate_dormant_users

      User.dormant_that_can_be_deactivated.find_each { |user| deactivate(user) }

      User.with_no_activity_that_can_be_deactivated.find_each { |user| deactivate(user) }
    end

    private

    def deactivate(user)
      if user.can_be_deactivated?
        with_context(user: user) { user.deactivate }
      end
    end
  end
end
