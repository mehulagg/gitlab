# frozen_string_literal: true

module Users
  class DeactivateDormantUsersWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include CronjobQueue

    feature_category :utilization

    def perform
      return unless ::Gitlab::CurrentSettings.current_application_settings.deactivate_dormant_users

      User.dormant.find_each do |user|
        if user.can_be_deactivated?
          with_context(user: user) { user.deactivate }
        end
      end
    end
  end
end
