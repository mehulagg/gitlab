# frozen_string_literal: true

class MigrateDefaultDiffMaxPatchBytesToMinimum200kb < ActiveRecord::Migration[6.0]
  DOWNTIME = false
  MAX_SIZE = Gitlab::Git::Diff::DEFAULT_MAX_PATCH_BYTES

  class ApplicationSetting < ActiveRecord::Base
    self.table_name = 'application_settings'
  end

  def up
    table = ApplicationSetting.arel_table
    ApplicationSetting.where(table[:diff_max_patch_bytes].lt(MAX_SIZE)).update_all(diff_max_patch_bytes: MAX_SIZE)
  end

  def down
    # no-op
  end
end
