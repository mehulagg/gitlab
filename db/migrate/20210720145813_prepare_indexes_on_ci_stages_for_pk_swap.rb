# frozen_string_literal: true

class PrepareIndexesOnCiStagesForPkSwap < ActiveRecord::Migration[6.1]
  include Gitlab::Database::MigrationHelpers

  TABLE_NAME = 'ci_stages'

  def up
    prepare_async_index TABLE_NAME, :id_convert_to_bigint, unique: true, name: 'index_ci_stages_on_id_convert_to_bigint'

    # This will replace the existing ci_stages_on_pipeline_id_and_id index
    prepare_async_index TABLE_NAME, [:pipeline_id, :id_convert_to_bigint],
                         name: 'index_ci_stages_on_pipeline_id_and_id_convert_to_bigint',
                         where: 'status in (0, 1, 2, 8, 9, 10)'
  end

  def down
    unprepare_async_index TABLE_NAME, :id_convert_to_bigint, unique: true, name: 'index_ci_stages_on_id_convert_to_bigint'

    # This will replace the existing ci_stages_on_pipeline_id_and_id index
    unprepare_async_index TABLE_NAME, [:pipeline_id, :id_convert_to_bigint],
                         name: 'index_ci_stages_on_pipeline_id_and_id_convert_to_bigint',
                         where: 'status in (0, 1, 2, 8, 9, 10)'
  end
end
