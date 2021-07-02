# frozen_string_literal: true

class UserProjectAccessChangedService
  DELAY = 1.hour

  HIGH_PRIORITY = :high
  LOW_PRIORITY = :low

  def initialize(user_ids)
    @user_ids = Array.wrap(user_ids)
  end

  def execute(blocking: true, priority: HIGH_PRIORITY)
    bulk_args = @user_ids.map { |id| [id] }

    result =
      if blocking
        AuthorizedProjectsWorker.bulk_perform_and_wait(bulk_args)
      else
        if priority == HIGH_PRIORITY
          AuthorizedProjectsWorker.bulk_perform_async(bulk_args) # rubocop:disable Scalability/BulkPerformWithContext
        else
          current_caller_id = Gitlab::ApplicationContext.current_context_attribute('meta.caller_id').presence

          if current_caller_id
            bulk_args = @user_ids.map { |id| [id, current_caller_id] }
          end

          AuthorizedProjectUpdate::UserRefreshFromReplicaWorker.bulk_perform_in( # rubocop:disable Scalability/BulkPerformWithContext
            DELAY, bulk_args, batch_size: 100, batch_delay: 30.seconds)
        end
      end

    ::Gitlab::Database::LoadBalancing::Sticking.bulk_stick(:user, @user_ids)

    result
  end
end
