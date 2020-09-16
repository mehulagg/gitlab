# frozen_string_literal: true

module AdminNotify
  def notify_admins
    return unless Gitlab.ee? && License.current.nil?
    return unless License.current&.active_user_count_threshold_reached?

    User
      .active
      .admins
      .select(:id)
      .map { |admin| LicenseMailer.approaching_active_user_count_limit(admin) }
  end
end
