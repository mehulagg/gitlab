# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    class RemoveCommaFromWeightSystemNotes
      def perform(note_ids)
        notes_table = Arel::Table.new(:notes)

        update_values = [
          [notes_table[:note], Arel.sql("TRIM(TRAILING ',' FROM note)")],
          [notes_table[:note_html], nil]
        ]

        update = Arel::UpdateManager.new
                   .table(notes_table)
                   .set(update_values)
                   .where(notes_table[:id].in(note_ids))

        ActiveRecord::Base.connection.execute(update.to_sql)
      end
    end
  end
end
