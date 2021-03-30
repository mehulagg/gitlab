# frozen_string_literal: true

class RemoveRecordsWithoutGroupFromWebhooksTable < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  class WebHook < ActiveRecord::Base
    include EachBatch

    self.table_name = 'web_hooks'
  end

  class Group < ActiveRecord::Base
    self.table_name = 'namespaces'
  end

  def up
    WebHook.where(type: 'GroupHook')
           .where.not(group_id: nil)
           .where.not(group_id: Group.select(:id)).each_batch do |relation|
      relation.delete_all
    end
  end

  def down
    # no-op
  end
end
