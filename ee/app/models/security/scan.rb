# frozen_string_literal: true

module Security
  class Scan < ApplicationRecord
    include CreatedAtFilterable

    self.table_name = 'security_scans'

    validates :build_id, presence: true
    validates :scan_type, presence: true
    validates :info, json_schema: { filename: 'security_scan_info', draft: 7 }

    belongs_to :build, class_name: 'Ci::Build'

    has_one :pipeline, class_name: 'Ci::Pipeline', through: :build

    has_many :findings, inverse_of: :scan

    enum scan_type: {
      sast: 1,
      dependency_scanning: 2,
      container_scanning: 3,
      dast: 4,
      secret_detection: 5,
      coverage_fuzzing: 6,
      api_fuzzing: 7,
      cluster_image_scanning: 8
    }

    scope :by_scan_types, -> (scan_types) { where(scan_type: scan_types) }

    scope :has_dismissal_feedback, -> do
      # The `category` enum on `vulnerability_feedback` table starts from 0 but the `scan_type` enum
      # on `security_scans` from 1. For this reason, we have to decrease the value of `scan_type` by one
      # to match with category values on `vulnerability_feedback` table.
      joins(build: { project: :vulnerability_feedback })
        .where('vulnerability_feedback.category = (security_scans.scan_type - 1)')
        .merge(Vulnerabilities::Feedback.for_dismissal)
    end

    scope :latest, -> { joins(:build).where(ci_builds: { retried: [nil, false] }) }
    scope :latest_successful_by_build, -> { latest.where(ci_builds: { status: 'success' }) }
    scope :without_errors, -> { where("jsonb_array_length(COALESCE(info->'error', '[]'::jsonb)) = 0") }

    delegate :project, :name, to: :build

    def has_errors?
      info&.fetch('errors', []).present?
    end

    # Returns the findings from the source report
    def report_findings
      @report_findings ||= security_report.findings
    end

    private

    def security_report
      job_artifact.security_report
    end

    def job_artifact
      build.job_artifacts.find { |artifact| artifact.file_type == scan_type }
    end
  end
end
