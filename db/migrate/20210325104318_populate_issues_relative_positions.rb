# frozen_string_literal: true

class PopulateIssuesRelativePositions < ActiveRecord::Migration[6.0]
  DOWNTIME = false
  BATCH_SIZE = 10_000

  class Issue < ApplicationRecord
    include EachBatch

    self.table_name = 'issues'
  end

  class IssuesRelativePosition < ApplicationRecord
    include EachBatch

    self.table_name = 'issues_relative_positions'
  end

  def up
    Issue.each_batch(of: BATCH_SIZE) do |batch|
      values = build_values(batch)
      ActiveRecord::Base.connection.exec_query <<~SQL
        INSERT INTO #{IssuesRelativePosition.table_name} (issue_id, relative_position, bucket) VALUES #{values}
      SQL
    end
  end

  def down
    IssuesRelativePosition.each_batch(of: BATCH_SIZE) do |batch|
      batch.delete_all
    end
  end

  def build_values(issues)
    issues.select("id, relative_position, '0' as bucket").map { |x| "(#{x.id}, #{x.relative_position || 'NULL'}, #{x.bucket})"}.join(",")
  end
end
