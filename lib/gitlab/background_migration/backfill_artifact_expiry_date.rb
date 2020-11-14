# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # Backfill expire_at for a range of Ci::JobArtifact
    class BackfillArtifactExpiryDate
      # Ci::JobArtifact model
      class Ci::JobArtifact < ActiveRecord::Base
        self.table_name = 'ci_job_artifacts'

        scope :between, -> (start_id, end_id) { where(id: start_id..end_id) }

        scope :without_expiry_date, -> { where(expire_at: nil) }

        scope :old, -> { where(self.class.arel_table[:created_at].lt(15.months.ago)) }
        scope :new, -> { where(self.class.arel_table[:created_at].gt(15.months.ago)) }
      end

      def perform(start_id, end_id)
        Ci::JobArtifact.between(start_id, end_id).without_expiry_date.old.update(expire_at: Time.now + 3.months)
        Ci::JobArtifact.between(start_id, end_id).without_expiry_date.new.update(expire_at: Time.now + 1.year)
      end
    end
  end
end
