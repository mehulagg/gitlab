# frozen_string_literal: true

class Admin::BackgroundMigrationsController < Admin::ApplicationController
  feature_category :database

  def index
    @relations_by_tab = {
      'queued' => batched_migration_class.queued.queue_order,
      'failed' => batched_migration_class.aborted_or_failed.queue_order,
      'completed' => batched_migration_class.finished.queue_order.reverse_order
    }

    @current_tab = params[:tab].presence || 'queued'
    @migrations = @relations_by_tab[@current_tab].page(params[:page])
    @completed_rows_counts = batched_migration_class.completed_rows_counts(@migrations.map(&:id))
  end

  private

  def batched_migration_class
    Gitlab::Database::BackgroundMigration::BatchedMigration
  end
end
