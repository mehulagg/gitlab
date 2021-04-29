# frozen_string_literal: true

module Admin
  module BackgroundMigrationsHelper
    def batched_migration_status_badge_class_name(migration)
      if migration.active?
        'badge-info'
      elsif migration.paused?
        'badge-warning'
      elsif migration.aborted? || migration.failed?
        'badge-danger'
      elsif migration.finished?
        'badge-success'
      end
    end

    def batched_migration_progress(migration, completed_rows)
      return 100 if migration.finished?
      return unless migration.total_tuple_count

      [100 * completed_rows.to_i / migration.total_tuple_count, 99].min
    end
  end
end
