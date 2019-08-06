# frozen_string_literal: true

# This reverts migration 20190703001116_default_weight_to_nil.rb
class DefaultWeightToMinusOne < ActiveRecord::Migration[5.1]
  DOWNTIME = false

  def up
    execute(update_board_weights_query)
  end

  def down
    # no-op
  end

  private

  def update_board_weights_query
    <<~HEREDOC
   UPDATE boards
     SET weight = -1
   WHERE boards.weight = NULL
    HEREDOC
  end
end
