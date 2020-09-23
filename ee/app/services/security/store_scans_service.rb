# frozen_string_literal: true

module Security
  class StoreScansService
    def initialize(build)
      @build = build
    end

    def execute
      return if canceled_or_skipped?

      security_reports.each { |_, report| store_scan_for(report) }
    end

    private

    attr_reader :build

    def canceled_or_skipped?
      build.canceled? || build.skipped?
    end

    def security_reports
      ::Gitlab::Ci::Reports::Security::Reports.new(self).tap do |security_reports|
        build.collect_security_reports!(security_reports)
      end
    end

    def store_scan_for(report)
      ActiveRecord::Base.transaction do
        security_scan = Security::Scan.safe_find_or_create_by!(build: build, scan_type: report.type)

        StoreFindingsMetadataService.execute(security_scan, report)
      end
    end
  end
end
