module EE
  module Ci
    module Pipeline
      extend ActiveSupport::Concern

      EE_FAILURE_REASONS = {
        activity_limit_exceeded: 20,
        size_limit_exceeded: 21
      }.freeze

      prepended do
        has_one :chat_data, class_name: 'Ci::PipelineChatData'

        # Legacy way to fetch security reports based on job name. This has been replaced by the reports feature.
        scope :with_security_reports, -> {
          joins(:artifacts).where(ci_builds: { name: %w[sast dependency_scanning sast:container container_scanning dast] })
        }

        state_machine :status do
          after_transition any => ::Ci::Pipeline::COMPLETED_STATUSES.map(&:to_sym) do |pipeline|
            next unless pipeline.has_security_reports?

            pipeline.run_after_commit do
              SecurityReportsWorker.perform_async(pipeline.id)
            end
          end
        end
      end

      # codeclimate_artifact is deprecated and replaced with code_quality_artifact (#5779)
      def codeclimate_artifact
        @codeclimate_artifact ||= artifacts_with_files.find(&:has_codeclimate_json?)
      end

      def code_quality_artifact
        @code_quality_artifact ||= artifacts_with_files.find(&:has_code_quality_json?)
      end

      def performance_artifact
        @performance_artifact ||= artifacts_with_files.find(&:has_performance_json?)
      end

      def sast_artifact
        @sast_artifact ||= artifacts_with_files.find(&:has_sast_json?)
      end

      def dependency_scanning_artifact
        @dependency_scanning_artifact ||= artifacts_with_files.find(&:has_dependency_scanning_json?)
      end

      def license_management_artifact
        @license_management_artifact ||= artifacts_with_files.find(&:has_license_management_json?)
      end

      # sast_container_artifact is deprecated and replaced with container_scanning_artifact (#5778)
      def sast_container_artifact
        @sast_container_artifact ||= artifacts_with_files.find(&:has_sast_container_json?)
      end

      def container_scanning_artifact
        @container_scanning_artifact ||= artifacts_with_files.find(&:has_container_scanning_json?)
      end

      def dast_artifact
        @dast_artifact ||= artifacts_with_files.find(&:has_dast_json?)
      end

      def has_sast_data?
        sast_artifact&.success?
      end

      def has_dependency_scanning_data?
        dependency_scanning_artifact&.success?
      end

      def has_license_management_data?
        license_management_artifact&.success?
      end

      # has_sast_container_data? is deprecated and replaced with has_container_scanning_data? (#5778)
      def has_sast_container_data?
        sast_container_artifact&.success?
      end

      def has_container_scanning_data?
        container_scanning_artifact&.success?
      end

      def has_dast_data?
        dast_artifact&.success?
      end

      def has_performance_data?
        performance_artifact&.success?
      end

      # has_codeclimate_data? is deprecated and replaced with has_code_quality_data? (#5779)
      def has_codeclimate_data?
        codeclimate_artifact&.success?
      end

      def has_code_quality_data?
        code_quality_artifact&.success?
      end

      def expose_sast_data?
        project.feature_available?(:sast) &&
          has_sast_data?
      end

      def expose_dependency_scanning_data?
        project.feature_available?(:dependency_scanning) &&
          has_dependency_scanning_data?
      end

      def expose_license_management_data?
        project.feature_available?(:license_management) &&
          has_license_management_data?
      end

      # expose_sast_container_data? is deprecated and replaced with expose_container_scanning_data? (#5778)
      def expose_sast_container_data?
        project.feature_available?(:sast_container) &&
          has_sast_container_data?
      end

      def expose_container_scanning_data?
        project.feature_available?(:sast_container) &&
          has_container_scanning_data?
      end

      def expose_dast_data?
        project.feature_available?(:dast) &&
          has_dast_data?
      end

      def expose_performance_data?
        project.feature_available?(:merge_request_performance_metrics) &&
          has_performance_data?
      end

      def expose_security_dashboard?
        expose_sast_data? ||
          expose_dependency_scanning_data? ||
          expose_dast_data? ||
          expose_sast_container_data? ||
          expose_container_scanning_data?
      end

      # expose_codeclimate_data? is deprecated and replaced with expose_code_quality_data? (#5779)
      def expose_codeclimate_data?
        has_codeclimate_data?
      end

      def expose_code_quality_data?
        has_code_quality_data?
      end

      def has_security_reports?
        complete? && builds.latest.with_security_reports.any?
      end

      def security_reports
        ::Gitlab::Ci::Reports::Security::Reports.new(self).tap do |security_reports|
          builds.latest.with_security_reports.each do |build|
            build.collect_security_reports!(security_reports)
          end
        end
      end

      private

      def artifacts_with_files
        @artifacts_with_files ||= artifacts.includes(:job_artifacts_metadata, :job_artifacts_archive).to_a
      end
    end
  end
end
