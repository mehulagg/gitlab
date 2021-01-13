# frozen_string_literal: true

class AddContextToExperimentSubjects < ActiveRecord::Migration[6.0]
  include Gitlab::Database::MigrationHelpers

  DOWNTIME = false

  def up
    with_lock_retries do
      add_column :experiment_subjects, :context, :jsonb, default: {}, null: false
    end
  end

  def down
    with_lock_retries do
      remove_column :experiment_subjects, :context
    end
  end
end
