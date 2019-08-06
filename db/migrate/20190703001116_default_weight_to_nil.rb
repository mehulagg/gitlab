# frozen_string_literal: true

class DefaultWeightToNil < ActiveRecord::Migration[5.1]
  DOWNTIME = false

  def up
    execute(update_board_weights_query)
  end

  def down
    # no-op
  end

  private

  # Only 288 records to update, as of 2019/07/18
  def update_board_weights_query
    <<~HEREDOC
   UPDATE boards
     SET weight = NULL
   WHERE boards.weight = -1
    HEREDOC
  end
end
