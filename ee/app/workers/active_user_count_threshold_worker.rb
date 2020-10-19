# frozen_string_literal: true

class ActiveUserCountThresholdWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  # rubocop:disable Scalability/CronWorkerContext
  # This worker does not perform work scoped to a context
  include CronjobQueue
  # rubocop:enable Scalability/CronWorkerContext

  feature_category :provision

  def perform
    License.with_valid_license do |license|
      break unless license.active_user_count_threshold_reached?

      # rubocop:disable CodeReuse/ActiveRecord
      recipients = User
        .active
        .admins
        .pluck(:email)
        .to_set
      # rubocop:enable CodeReuse/ActiveRecord

      recipients << license.licensee["Email"] if license.licensee["Email"]

      LicenseMailer.approaching_active_user_count_limit(recipients.to_a)
    end
  end
end
