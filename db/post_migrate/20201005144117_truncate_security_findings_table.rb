# frozen_string_literal: true

class TruncateSecurityFindingsTable < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  disable_ddl_transaction!

  def up
    ActiveRecord::Base.connection.execute('TRUNCATE security_findings RESTART IDENTITY')
  end

  def down
    # no-op we don't need the down method for this migration
  end
end
