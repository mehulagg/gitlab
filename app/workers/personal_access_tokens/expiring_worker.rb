# frozen_string_literal: true

module PersonalAccessTokens
  class ExpiringWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include CronjobQueue

    feature_category :authentication_and_authorization

    # rubocop: disable CodeReuse/ActiveRecord
    def perform(*args)
      notification_service = NotificationService.new
      limit_date = PersonalAccessToken::DAYS_TO_EXPIRE.days.from_now.to_date

      User.with_expiring_and_not_notified_personal_access_tokens(limit_date).find_each do |user|
        with_context(user: user) do
          expiring_user_tokens = user.personal_access_tokens.without_impersonation.expiring_and_not_notified(limit_date)
          token_names = expiring_user_tokens.pluck(:name)

          notification_service.access_token_about_to_expire(user, token_names)

          Gitlab::AppLogger.info "#{self.class}: Notifying User #{user.id} about expiring tokens"

          expiring_user_tokens.update_all(expire_notification_delivered: true)
        end
      end
    end
    # rubocop: enable CodeReuse/ActiveRecord
  end
end
