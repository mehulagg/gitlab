# frozen_string_literal: true

class CopyPendingBuildsToPendingBuildsTable < ActiveRecord::Migration[6.0]
  def up
    execute "SET statement_timeout='1s'"
    execute "SELECT pg_sleep(2)"
  end

  def down
    # noop
  end
end
