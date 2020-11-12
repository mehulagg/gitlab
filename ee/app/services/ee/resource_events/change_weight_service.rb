# frozen_string_literal: true

module EE
  module ResourceEvents
    class ChangeWeightService
      attr_reader :resources, :user, :event_created_at

      def initialize(resources, user, created_at)
        @resources = resources
        @user = user
        @event_created_at = created_at
      end

      def execute
        unless resource_weight_changes.empty?
          ::Gitlab::Database.bulk_insert(ResourceWeightEvent.table_name, resource_weight_changes) # rubocop:disable Gitlab/BulkInsert
          resources.each(&:expire_note_etag_cache)
        end
      end

      private

      def resource_weight_changes
        @weight_changes ||= resources.map do |resource|
          changes = []
          base_data = { user_id: user.id, issue_id: resource.id }

          changes << base_data.merge({ weight: resource.previous_weight, created_at: resource.previous_updated_at }) if resource.first_weight_event?
          changes << base_data.merge({ weight: resource.weight, created_at: event_created_at })
        end.flatten
      end
    end
  end
end
