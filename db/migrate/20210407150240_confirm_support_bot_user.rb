# frozen_string_literal: true

class ConfirmSupportBotUser < ActiveRecord::Migration[6.0]
  def up
    users = Arel::Table.new(:users)
    um = Arel::UpdateManager.new
    um.table(users)
      .where(users[:user_type].eq(1))
      .where(users[:confirmed_at].eq(nil))
      .set([[users[:confirmed_at], users[:created_at]]])
    connection.execute(um.to_sql)
  end

  def down
    # no op

    # The up migration allows for the possibility that the support user might 
    # have already been manually confirmed. It's not reversible as this data is
    # subsequently lost.
  end
end
