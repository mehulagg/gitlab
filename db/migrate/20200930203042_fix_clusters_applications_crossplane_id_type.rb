# frozen_string_literal: true

class FixClustersApplicationsCrossplaneIdType < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    change_column :clusters_applications_crossplane, :id, :bigint
  end

  def down
    # no op
  end
end
