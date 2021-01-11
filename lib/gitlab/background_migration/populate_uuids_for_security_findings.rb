# frozen_string_literal: true

module Gitlab
  module BackgroundMigration
    # This class populates the `finding_uuid` attribute for
    # the existing `vulnerability_feedback` records.
    class PopulateUuidsForSecurityFindings
      class Artifact < ActiveRecord::Base
        include FileStoreMounter

        NotSupportedAdapterError = Class.new(StandardError)

        FILE_FORMAT_ADAPTERS = {
          gzip: Gitlab::Ci::Build::Artifacts::Adapters::GzipStream,
          raw: Gitlab::Ci::Build::Artifacts::Adapters::RawStream
        }.freeze

        self.table_name = :ci_job_artifacts

        mount_file_store_uploader JobArtifactUploader

        belongs_to :build, class_name: '::Gitlab::BackgroundMigration::PopulateUuidsForSecurityFindings::Build', foreign_key: :job_id

        enum file_type: {
          trace: 3,
          sast: 5,
          dependency_scanning: 6,
          container_scanning: 7,
          dast: 8,
          secret_detection: 21,
          coverage_fuzzing: 23,
          api_fuzzing: 26
        }

        enum file_format: {
          raw: 1,
          zip: 2,
          gzip: 3
        }, _suffix: true

        enum file_location: {
          legacy_path: 1,
          hashed_path: 2
        }

        def security_report
          return if expired? || !build&.pipeline

          report = ::Gitlab::Ci::Reports::Security::Report.new(file_type, build.pipeline, nil).tap do |report|
            each_blob do |blob|
              ::Gitlab::Ci::Parsers.fabricate!(file_type, blob, report).parse!
            end
          end

          ::Security::MergeReportsService.new(report).execute
        end

        # Used by the `JobArtifactUploader`
        def hashed_path?
          return true if trace?

          super || self.file_location.nil?
        end

        private

        def expired?
          expire_at.present? && expire_at < Time.current
        end

        # Copied from Ci::Artifactable
        def each_blob(&blk)
          unless file_format_adapter_class
            raise NotSupportedAdapterError, 'This file format requires a dedicated adapter'
          end

          file.open do |stream|
            file_format_adapter_class.new(stream).each_blob(&blk)
          end
        end

        def file_format_adapter_class
          FILE_FORMAT_ADAPTERS[file_format.to_sym]
        end
      end

      class Pipeline < ActiveRecord::Base
        self.table_name = :ci_pipelines
      end

      class Build < ActiveRecord::Base
        self.table_name = :ci_builds
        self.inheritance_column = nil

        belongs_to :pipeline, class_name: '::Gitlab::BackgroundMigration::PopulateUuidsForSecurityFindings::Pipeline', foreign_key: :commit_id
        has_many :artifacts, class_name: '::Gitlab::BackgroundMigration::PopulateUuidsForSecurityFindings::Artifact', foreign_key: :job_id
      end

      class SecurityScan < ActiveRecord::Base
        self.table_name = :security_scans

        belongs_to :build, class_name: '::Gitlab::BackgroundMigration::PopulateUuidsForSecurityFindings::Build'
        has_many :artifacts, through: :build
        has_many :findings, class_name: '::Gitlab::BackgroundMigration::PopulateUuidsForSecurityFindings::SecurityFinding', foreign_key: :scan_id

        enum scan_type: {
          sast: 1,
          dependency_scanning: 2,
          container_scanning: 3,
          dast: 4,
          secret_detection: 5,
          coverage_fuzzing: 6,
          api_fuzzing: 7
        }

        def populate_finding_uuids
          report_findings.each_with_index do |report_finding, index|
            findings.where(position: index)
                    .update_all(uuid: report_finding.uuid)
          end
        end

        private

        def report_findings
          security_reports&.findings.to_a
        end

        def security_reports
          related_artifact&.security_report
        end

        def related_artifact
          artifacts.find { |artifact| artifact.file_type == scan_type }
        end
      end

      class SecurityFinding < ActiveRecord::Base
        include EachBatch

        self.table_name = :security_findings

        scope :without_uuid, -> { where(uuid: nil) }
      end

      def perform(scan_ids)
        SecurityScan.where(id: scan_ids).each(&:populate_finding_uuids)
      end
    end
  end
end
