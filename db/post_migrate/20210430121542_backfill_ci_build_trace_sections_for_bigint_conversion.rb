# frozen_string_literal: true

class BackfillCiBuildTraceSectionsForBigintConversion < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  TABLE = :ci_build_trace_sections
  COLUMN = :build_id

  def up
    return unless should_run?

    backfill_conversion_of_integer_to_bigint TABLE, COLUMN, batch_size: 15000, sub_batch_size: 100, primary_key: COLUMN
  end

  def down
    return unless should_run?

    revert_backfill_conversion_of_integer_to_bigint TABLE, COLUMN
  end

  private

  def should_run?
    Gitlab.dev_or_test_env? || Gitlab.com?
  end
end
