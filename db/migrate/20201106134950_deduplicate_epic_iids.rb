# frozen_string_literal: true

class DeduplicateEpicIids < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    duplicate_epic_ids = ApplicationRecord.connection.execute('SELECT iid, group_id, COUNT(*) FROM epics GROUP BY iid, group_id HAVING COUNT(*) > 1;')

    duplicate_epic_ids.each do |dup|
      Epic.where(iid: dup['iid'], group_id: dup['group_id']).first(dup['count'] - 1).each do |epic|
        new_iid = InternalId.generate_next(Epic, epic.internal_id_scope_attrs(:group), epic.internal_id_scope_usage, nil)
        epic.update(iid: new_iid)
      end
    end
  end

  def down
    # no-op
  end
end
