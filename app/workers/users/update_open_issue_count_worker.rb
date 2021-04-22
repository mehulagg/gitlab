# frozen_string_literal: true

module Users
  class UpdateOpenIssueCountWorker
    include ApplicationWorker

    feature_category :users
    idempotent!

    def perform(current_user_id, target_user_ids)
      target_user_ids = Array.wrap(target_user_ids)

      raise ArgumentError.new('No current user ID provided') unless current_user_id
      raise ArgumentError.new('No target user ID provided') if target_user_ids.empty?

      users = User.id_in(Array.wrap(current_user_id) + target_user_ids)
      current_user = users.select{|u| u.id == current_user_id }.first
      raise ArgumentError.new('Current user not found') unless current_user

      target_users = users.select {|u| target_user_ids.include?(u.id) }
      raise ArgumentError.new('No valid target user ID provided') if target_users.empty?

      target_users.each do |user|
        Users::UpdateAssignedOpenIssueCountService.new(current_user: current_user, target_user: user).execute
      end
    rescue => exception
      Gitlab::ErrorTracking.track_and_raise_for_dev_exception(exception)
    end
  end
end
