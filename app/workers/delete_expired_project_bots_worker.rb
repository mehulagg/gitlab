# frozen_string_literal: true

class DeleteExpiredProjectBotsWorker # rubocop:disable Scalability/IdempotentWorker
  include ApplicationWorker
  include CronjobQueue # rubocop:disable Scalability/CronWorkerContext

  #feature_category :authentication_and_authorization
 # worker_resource_boundary :cpu

  def perform
    User.where(user_type: 'project_bot') do |bots|
      Member.where(user_id: bots.ids) do |bot_members|
        bot_members.expired.destroy_all
      end
    end
  end
end
