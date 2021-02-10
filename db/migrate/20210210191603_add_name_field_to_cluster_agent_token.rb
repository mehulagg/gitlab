# frozen_string_literal: true

class AddNameFieldToClusterAgentToken < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  disable_ddl_transaction!

  def up
    unless column_exists?(:cluster_agent_tokens, :name)
      add_column :cluster_agent_tokens, :name, :text
    end

    add_text_limit :cluster_agent_tokens, :name, 255
  end

  def down
    remove_column :cluster_agent_tokens, :name
  end
end
