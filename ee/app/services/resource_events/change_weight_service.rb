# frozen_string_literal: true

module ResourceEvents
  class ChangeWeightService
    attr_reader :resource, :user, :event_created_at

    def initialize(resource, user, created_at)
      @resource = resource
      @user = user
      @event_created_at = created_at
    end

    def execute
      ::Gitlab::Database.bulk_insert(ResourceWeightEvent.table_name, resource_weight_changes) # rubocop:disable Gitlab/BulkInsert
      resource.expire_note_etag_cache

      Gitlab::UsageDataCounters::IssueActivityUniqueCounter.track_issue_weight_changed_action(author: user)
    end

    private

    def resource_weight_changes
      changes = []
      base_data = { user_id: user.id, issue_id: resource.id }

      changes << base_data.merge({ weight: resource.previous_weight, created_at: resource.previous_updated_at }) if resource.first_weight_event?
      changes << base_data.merge({ weight: resource.weight, created_at: event_created_at })

      changes
    end
  end
end
