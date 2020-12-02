# frozen_string_literal: true

module ContainerExpirationPolicies
  class TrackingService
    PACKAGE_EVENT_NAMES = {
      start: :expiration_policy_started,
      end: :expiration_policy_stopped,
      stop: :expiration_policy_ended
    }.freeze

    VALID_ACTIONS = PACKAGE_EVENT_NAMES.keys.freeze

    def initialize(container_repository)
      @container_repository = container_repository
    end

    def execute(action)
      raise ArgumentError, 'invalid container repository' unless @container_repository
      raise ArgumentError, 'invalid action' unless action.in?(VALID_ACTIONS)

      track_package_event(action)
      ::Gitlab::Tracking.event(self.class.name, action.to_s)

      update_container_repository!(action)
    end

    private

    def track_package_event(action)
      ::Packages::CreateEventService.new(
        nil,
        :worker,
        event_name: PACKAGE_EVENT_NAMES[action],
        scope: :container
      ).execute
    end

    def update_container_repository!(action)
      params = case action
               when :start
                 {
                   expiration_policy_cleanup_status: :cleanup_ongoing,
                   expiration_policy_started_at: Time.zone.now
                 }
               when :stop
                 {
                   expiration_policy_cleanup_status: :cleanup_unfinished,
                   expiration_policy_started_at: nil
                 }
               when :end
                 {
                   expiration_policy_cleanup_status: :cleanup_unscheduled,
                   expiration_policy_started_at: nil
                 }
               end

      @container_repository.update!(params)
    end
  end
end
