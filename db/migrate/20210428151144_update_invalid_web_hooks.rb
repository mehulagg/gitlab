# frozen_string_literal: true

class UpdateInvalidWebHooks < ActiveRecord::Migration[6.0]
  def up
    WebHook.where(type: 'ProjectHook')
           .where.not(project_id: nil)
           .where.not(group_id: nil)
           .update_all(group_id: nil)
  end

  def down
    # no-op
  end
end
