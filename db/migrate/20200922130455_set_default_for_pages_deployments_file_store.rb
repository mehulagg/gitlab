# frozen_string_literal: true

class SetDefaultForPagesDeploymentsFileStore < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  DEFAULT_LOCAL_STORE = 1

  def change
    change_column_default(:pages_deployments, :file_store, from: nil, to: DEFAULT_LOCAL_STORE)
  end
end
