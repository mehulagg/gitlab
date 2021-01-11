# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # This class populates the `finding_uuid` attribute for
    # the existing `vulnerability_feedback` records.
    class PopulateUuidsForSecurityFindings
      class Artifact < ActiveRecord::Base
        self.table_name = :ci_job_artifacts

        belongs_to :build, class_name: 'Gitlab::BackgroundMigration::PopulateUuidValuesForSecurityFindings::Build'
      end

      class Build < ActiveRecord::Base
        self.table_name = :ci_builds

        has_many :artifacts, class_name: 'Gitlab::BackgroundMigration::PopulateUuidValuesForSecurityFindings::Artifact'
      end

      class SecurityScan < ActiveRecord::Base
        self.table_name = :security_scans

        belongs_to :build, class_name: 'Gitlab::BackgroundMigration::PopulateUuidValuesForSecurityFindings::Build'
        has_many :findings, class_name: 'Gitlab::BackgroundMigration::PopulateUuidValuesForSecurityFindings::SecurityFinding'
      end

      class SecurityFinding < ActiveRecord::Base
        include EachBatch

        self.table_name = :security_findings

        scope :without_uuid, -> { where(uuid: nil) }
      end
    end
  end
end
