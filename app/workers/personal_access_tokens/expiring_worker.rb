# frozen_string_literal: true

module PersonalAccessTokens
  class ExpiringWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker
    include CronjobQueue

    feature_category :authentication_and_authorization
    BATCH_SIZE = 10

    def perform(*args)
      notification_service = NotificationService.new
      limit_date = PersonalAccessToken::DAYS_TO_EXPIRE.days.from_now.to_date

      User.with_expiring_and_not_notified_personal_access_tokens(limit_date).find_each do |user|
        with_context(user: user) do
          expiring_user_tokens = user.personal_access_tokens.without_impersonation.expiring_and_not_notified(limit_date)
          expiring_user_tokens.each_batch(of: BATCH_SIZE) do |expiring_tokens|
            # rubocop: disable CodeReuse/ActiveRecord
            # We never materialise the token instances. We need the names to mention them in the
            # email. Later we trigger an update query on the entire relation, not on individual instances.
            token_names = expiring_tokens.pluck(:name)
            # rubocop: enable CodeReuse/ActiveRecord

            notification_service.access_token_about_to_expire(user, token_names)

            Gitlab::AppLogger.info "#{self.class}: Notifying User #{user.id} about expiring tokens"

            expiring_tokens.update_all(expire_notification_delivered: true)
          end
        end
      end
    end
  end
end
