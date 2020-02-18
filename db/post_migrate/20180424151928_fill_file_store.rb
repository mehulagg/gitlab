class FillFileStore < ActiveRecord::Migration[4.2]
  DOWNTIME = false

  def up
    # no-op

    # This migration has been made a no-op because of the background
    # migration has been rescheduled. Otherwise the background migration
    # would be scheduled  multiple times on systems that are upgrading
    # multiple releases at once.
  end

  def down
    # no-op
  end
end
