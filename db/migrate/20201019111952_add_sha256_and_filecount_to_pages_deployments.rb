# frozen_string_literal: true

class AddSha256AndFilecountToPagesDeployments < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def change
    reversible do |dir|
      dir.up do
        # pages_deployments were never enabled on any production/staging
        # environments, so we safely delete them for people who enabled
        # them locally
        execute "DELETE FROM pages_deployments"
      end
      dir.down {}
    end

    # rubocop:disable Rails/NotNullColumn
    add_column :pages_deployments, :file_count, :integer, null: false
    add_column :pages_deployments, :file_sha256, :bytea, null: false
    # rubocop:enable Rails/NotNullColumn
  end
end
