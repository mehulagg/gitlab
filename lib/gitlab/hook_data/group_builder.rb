# frozen_string_literal: true

module Gitlab
  module HookData
    class GroupBuilder < BaseBuilder
      alias_method :group, :object

      # Sample data

      def build(event)
        [
          timestamps_data,
          event_data(event),
          group_data,
          event_specific_group_data(event)
        ].reduce(:merge)
      end

      private

      def group_data
        owner = group.owner

        {
          name: group.name,
          path: group.path,
          full_path: group.full_path,
          group_id: group.id,
          owner_name: owner.try(:name),
          owner_email: owner.try(:email)
        }
      end

      def event_specific_group_data(event)
        return {} unless event == :rename

        {
          old_path: group.path_before_last_save,
          old_full_path: group.full_path_before_last_save
        }
      end
    end
  end
end
