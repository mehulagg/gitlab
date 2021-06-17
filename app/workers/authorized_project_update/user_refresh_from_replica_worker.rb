# frozen_string_literal: true

module AuthorizedProjectUpdate
  class UserRefreshFromReplicaWorker # rubocop:disable Scalability/IdempotentWorker
    include ApplicationWorker

    sidekiq_options retry: 3
    feature_category :authentication_and_authorization
    urgency :low
    queue_namespace :authorized_project_update

    # This job will not be deduplicated since it is marked with
    # `data_consistency :delayed` and not `idempotent!`
    # See https://gitlab.com/gitlab-org/gitlab/-/issues/325291
    deduplicate :until_executing, including_scheduled: true

    data_consistency :delayed, feature_flag: :load_balancing_for_user_refresh_from_replica_worker

    def perform(user_id)
      user = User.find_by_id(user_id)
      return unless user

      enqueue_project_authorizations_refresh(user) if project_authorizations_needs_refresh?(user)
    end

    private

    def project_authorizations_needs_refresh?(user)
      AuthorizedProjectUpdate::FindRecordsDueForRefreshService.new(user).needs_refresh?
    end

    def enqueue_project_authorizations_refresh(user)
      with_context(user: user) do
        AuthorizedProjectUpdate::UserRefreshWithLowUrgencyWorker.perform_async(user.id)
      end
    end
  end
end
