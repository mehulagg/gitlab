# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      module MoveEpicIssuesAfterEpics
        extend ::Gitlab::Utils::Override

        class EpicIssue < ActiveRecord::Base
          self.table_name = 'epic_issues'
        end

        class Epic < ActiveRecord::Base
          self.table_name = 'epics'
        end

        override :perform
        def perform(start_id, stop_id)
          maximum_epic_position = Epic.maximum(:relative_position)

          return unless maximum_epic_position

          max_position = ::Gitlab::Database::MAX_INT_VALUE
          delta = ((maximum_epic_position - max_position) / 2.0).abs.ceil

          EpicIssue.where(epic_id: start_id..stop_id).where('relative_position < ?', max_position - delta)
            .update_all("relative_position = relative_position + #{delta}")
        end
      end
    end
  end
end
