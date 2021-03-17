# frozen_string_literal: true

class SetIterationCadenceAutomaticToFalse < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    Iterations::Cadence.is_automatic(true).update_all(automatic: false)
  end

  def down
    #  no-op
  end
end
