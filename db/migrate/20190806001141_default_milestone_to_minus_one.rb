# frozen_string_literal: true

# This reverts 20190703001120_default_milestone_to_nil.rb
class DefaultMilestoneToMinusOne < ActiveRecord::Migration[5.1]
  DOWNTIME = false

  def up
    execute(update_board_milestones_query)
  end

  def down
    # no-op
  end

  private

  def update_board_milestones_query
    <<~HEREDOC
   UPDATE boards
     SET milestone_id = -1
   WHERE boards.milestone_id = NULL
    HEREDOC
  end
end
