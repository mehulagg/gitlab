# frozen_string_literal: true

class BackfillPkConversionForSelfManaged < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  CONVERSIONS = {
    events: %i(id),
    push_event_payloads: %i(event_id),
    ci_build_needs: %i(build_id),
    ci_job_artifacts: %i(id job_id),
    ci_sources_pipelines: %i(source_job_id),
    ci_builds: %i(id stage_id),
    ci_build_trace_chunks: %i(build_id),
    ci_builds_runner_session: %i(build_id)
  }

  def up
    return unless should_run?

    CONVERSIONS.each do |table, columns|
      backfill_conversion_of_integer_to_bigint(table, columns)
    end
  end

  def down
    return unless should_run?

    CONVERSIONS.each do |table, columns|
      revert_backfill_conversion_of_integer_to_bigint(table, columns)
    end
  end

  private

  def should_run?
    !(Gitlab.dev_or_test_env? || Gitlab.com?)
  end
end
