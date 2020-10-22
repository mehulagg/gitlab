# frozen_string_literal: true

class DeleteExpiredProjectBotsWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

  feature_category :authentication_and_authorization
  worker_resource_boundary :cpu

  # rubocop: disable CodeReuse/ActiveRecord
  def perform
    User.where(user_type: 'project_bot') do |bots|
      Member.where(user_id: bots.ids).where('expires_at <= ?', Date.today) do |expired_bots|
        expired_bots.delete_all

        expired_bots.each do |delete_bot|
          User.where(id: delete_bot.user_id).delete
        end
      end
    end
  end
end
