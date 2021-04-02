# frozen_string_literal: true

module EE
  module Ci
    # Build EE mixin
    #
    # This module is intended to encapsulate EE-specific model logic
    # and be included in the `Build` model
    module Build
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      LICENSED_PARSER_FEATURES = {
        sast: :sast,
        secret_detection: :secret_detection,
        dependency_scanning: :dependency_scanning,
        container_scanning: :container_scanning,
        dast: :dast,
        coverage_fuzzing: :coverage_fuzzing,
        api_fuzzing: :api_fuzzing
      }.with_indifferent_access.freeze

      EE_RUNNER_FEATURES = {
        vault_secrets: -> (build) { build.ci_secrets_management_available? && build.secrets? }
      }.freeze

      prepended do
        include UsageStatistics
        include FromUnion

        has_many :security_scans, class_name: 'Security::Scan'

        after_save :stick_build_if_status_changed
        after_commit :track_ci_secrets_management_usage, on: :create
        delegate :service_specification, to: :runner_session, allow_nil: true

        scope :license_scan, -> { joins(:job_artifacts).merge(::Ci::JobArtifact.license_scanning_reports) }
        scope :max_build_id_by, -> (build_name, ref, project_path) do
          select('max(ci_builds.id) as id')
            .by_name(build_name)
            .for_ref(ref)
            .for_project_paths(project_path)
        end
      end

      override :variables
      def variables
        strong_memoize(:variables) do
          super.tap do |collection|
            if pipeline.triggered_for_ondemand_dast_scan? && pipeline.dast_profile
              collection.concat(pipeline.dast_profile.ci_variables)
            end
          end
        end
      end

      def shared_runners_minutes_limit_enabled?
        project.shared_runners_minutes_limit_enabled? && runner&.minutes_cost_factor(project.visibility_level)&.positive?
      end

      def stick_build_if_status_changed
        return unless saved_change_to_status?
        return unless running?

        ::Gitlab::Database::LoadBalancing::Sticking.stick(:build, id)
      end

      def log_geo_deleted_event
        # It is not needed to generate a Geo deleted event
        # since Legacy Artifacts are migrated to multi-build artifacts
        # See https://gitlab.com/gitlab-org/gitlab-foss/issues/46652
      end

      def has_artifact?(name)
        options.dig(:artifacts, :paths)&.include?(name) &&
          artifacts_metadata?
      end

      def collect_security_reports!(security_reports)
        each_report(::Ci::JobArtifact::SECURITY_REPORT_FILE_TYPES) do |file_type, blob, report_artifact|
          security_reports.get_report(file_type, report_artifact).tap do |security_report|
            next unless project.feature_available?(LICENSED_PARSER_FEATURES.fetch(file_type))

            parse_security_artifact_blob(security_report, blob)
          rescue => e
            security_report.error = e
          end
        end
      end

      def collect_license_scanning_reports!(license_scanning_report)
        return license_scanning_report unless project.feature_available?(:license_scanning)

        each_report(::Ci::JobArtifact::LICENSE_SCANNING_REPORT_FILE_TYPES) do |file_type, blob|
          ::Gitlab::Ci::Parsers.fabricate!(file_type).parse!(blob, license_scanning_report)
        end

        license_scanning_report
      end

      def collect_dependency_list_reports!(dependency_list_report)
        if project.feature_available?(:dependency_scanning)
          dependency_list = ::Gitlab::Ci::Parsers::Security::DependencyList.new(project, sha, pipeline)

          each_report(::Ci::JobArtifact::DEPENDENCY_LIST_REPORT_FILE_TYPES) do |_, blob|
            dependency_list.parse!(blob, dependency_list_report)
          end
        end

        dependency_list_report
      end

      def collect_licenses_for_dependency_list!(dependency_list_report)
        if project.feature_available?(:dependency_scanning)
          dependency_list = ::Gitlab::Ci::Parsers::Security::DependencyList.new(project, sha, pipeline)

          each_report(::Ci::JobArtifact::LICENSE_SCANNING_REPORT_FILE_TYPES) do |_, blob|
            dependency_list.parse_licenses!(blob, dependency_list_report)
          end
        end

        dependency_list_report
      end

      def collect_metrics_reports!(metrics_report)
        each_report(::Ci::JobArtifact::METRICS_REPORT_FILE_TYPES) do |file_type, blob|
          next unless project.feature_available?(:metrics_reports)

          ::Gitlab::Ci::Parsers.fabricate!(file_type).parse!(blob, metrics_report)
        end

        metrics_report
      end

      def collect_requirements_reports!(requirements_report)
        return requirements_report unless project.feature_available?(:requirements)

        each_report(::Ci::JobArtifact::REQUIREMENTS_REPORT_FILE_TYPES) do |file_type, blob, report_artifact|
          ::Gitlab::Ci::Parsers.fabricate!(file_type).parse!(blob, requirements_report)
        end

        requirements_report
      end

      def ci_secrets_management_available?
        return false unless project

        project.feature_available?(:ci_secrets_management)
      end

      override :runner_required_feature_names
      def runner_required_feature_names
        super + ee_runner_required_feature_names
      end

      def secrets_provider?
        variable_value('VAULT_SERVER_URL').present?
      end

      def variable_value(key, default = nil)
        variables_hash.fetch(key, default)
      end

      private

      def variables_hash
        @variables_hash ||= variables.map do |variable|
          [variable[:key], variable[:value]]
        end.to_h
      end

      def parse_security_artifact_blob(security_report, blob)
        report_clone = security_report.clone_as_blank
        ::Gitlab::Ci::Parsers.fabricate!(security_report.type, blob, report_clone).parse!
        security_report.merge!(report_clone)
      end

      def ee_runner_required_feature_names
        strong_memoize(:ee_runner_required_feature_names) do
          EE_RUNNER_FEATURES.select do |feature, method|
            method.call(self)
          end.keys
        end
      end

      def track_ci_secrets_management_usage
        return unless ci_secrets_management_available? && secrets?

        ::Gitlab::UsageDataCounters::HLLRedisCounter.track_event('i_ci_secrets_management_vault_build_created', values: user_id)
      end
    end
  end
end
