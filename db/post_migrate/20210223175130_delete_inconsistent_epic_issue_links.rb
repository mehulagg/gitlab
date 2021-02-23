# frozen_string_literal: true

class DeleteInconsistentEpicIssueLinks < ActiveRecord::Migration[6.0]
  DOWNTIME = false
  BATCH_SIZE = 1000

  class EpicIssue < ActiveRecord::Base
    self.table_name = 'epic_issues'
    belongs_to :epic
    belongs_to :issue

    include ::EachBatch
  end

  def up
    return unless ::Gitlab.ee?

    Group.where(type: 'Group').joins(:epics).distinct.find_each do |group|
      EpicIssue.joins(:epic)
        .where(epics: { group_id: group })
        .joins(issue: :project)
        .where.not(projects: { namespace_id: group.self_and_descendants })
        .each_batch(of: BATCH_SIZE) do |batch|
          batch.delete_all
        end
    end
  end

  def down
    # no-op
  end
end
