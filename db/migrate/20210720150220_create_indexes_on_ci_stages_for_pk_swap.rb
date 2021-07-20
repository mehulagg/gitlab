# frozen_string_literal: true

class CreateIndexesOnCiStagesForPkSwap < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  TABLE_NAME = 'ci_stages'

  disable_ddl_transaction!

  def up
    add_concurrent_index TABLE_NAME, :id_convert_to_bigint, unique: true, name: 'index_ci_stages_on_id_convert_to_bigint'

    # This will replace the existing ci_stages_on_pipeline_id_and_id index
    add_concurrent_index TABLE_NAME, [:pipeline_id, :id_convert_to_bigint],
                         name: 'index_ci_stages_on_pipeline_id_and_id_convert_to_bigint',
                         where: 'status in (0, 1, 2, 8, 9, 10)'
  end

  def down
    remove_concurrent_index_by_name TABLE_NAME, 'index_ci_stages_on_id_convert_to_bigint'
    remove_concurrent_index_by_name TABLE_NAME, 'index_ci_stages_on_pipeline_id_and_id_convert_to_bigint'
  end
end
