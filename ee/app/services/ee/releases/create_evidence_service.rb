# frozen_string_literal: true

module EE
  module Releases
    module CreateEvidenceService
      extend ::Gitlab::Utils::Override

      def execute
        super

        keep_report_artifacts
      end

      override :evidence_options
      def evidence_options
        super.merge(
          report_artifacts: report_artifacts
        )
      end

      def report_artifacts
        return ::Ci::Build.none unless release.project.feature_available?(:release_evidence_test_artifacts)

        pipeline&.latest_report_builds || ::Ci::Build.none
      end

      def keep_report_artifacts
        report_artifacts.keep_artifacts!
      end
    end
  end
end
