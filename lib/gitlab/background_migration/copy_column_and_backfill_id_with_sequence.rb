# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    class CopyColumnAndBackfillIdWithSequence < CopyColumnUsingBackgroundMigrationJob
      def column_assignment_clauses(copy_from, copy_to)
        super + "id = DEFAULT"
      end
    end
  end
end
