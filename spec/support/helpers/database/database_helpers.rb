# frozen_string_literal: true

module Database
  module DatabaseHelpers
    def swapout_view_for_table(view)
      ActiveRecord::Base.connection.execute(<<~SQL)
        CREATE TABLE #{view}_copy (LIKE #{view});
        DROP VIEW #{view};
        ALTER TABLE #{view}_copy RENAME TO #{view};
      SQL
    end
  end
end
