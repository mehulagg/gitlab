# frozen_string_literal: true

module EE
  module QuickActions
    module TargetService
      def execute(type, type_id)
        return epic(type_id) if type.casecmp('epic') == 0

        super
      end

      private

      # rubocop: disable CodeReuse/ActiveRecord
      def epic(type_id)
        group = params[:group]

        return group.epics.build if type_id.nil?

        EpicsFinder.new(current_user, group_id: group).find_by(iid: type_id) || group.epics.build
      end
      # rubocop: enable CodeReuse/ActiveRecord
    end
  end
end
