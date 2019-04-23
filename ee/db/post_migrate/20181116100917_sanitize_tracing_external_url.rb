# frozen_string_literal: true

# See http://doc.gitlab.com/ce/development/migration_style_guide.html
# for more information on how to write migrations for GitLab.

class SanitizeTracingExternalUrl < ActiveRecord::Migration[4.2]
  include Gitlab::Database::MigrationHelpers

  # Set this constant to true if this migration requires downtime.
  DOWNTIME = false

  class ProjectTracingSetting < ActiveRecord::Base
    include ::EachBatch

    self.table_name = 'project_tracing_settings'

    def sanitize_external_url
      self.external_url = Rails::Html::FullSanitizer.new.sanitize(self.external_url)
    end
  end

  def up
    ProjectTracingSetting.each_batch(of: 50) do |batch|
      batch.each do |rec|
        rec.sanitize_external_url

        rec.save! if rec.changed?
      end
    end
  end

  def down
    # no-op
  end
end
