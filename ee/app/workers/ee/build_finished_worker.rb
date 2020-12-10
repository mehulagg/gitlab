# frozen_string_literal: true

module EE
  module BuildFinishedWorker
    def process_build(build)
      UpdateBuildMinutesService.new(build.project, nil).execute(build)
      # We need to use `reset` on `project` because their AR associations have been cached
      # and `Namespace#namespace_statistics` will return stale data.
      ::Ci::Minutes::EmailNotificationService.new(build.project.reset).execute if ::Gitlab.com?

      ScanSecurityReportSecretsWorker.perform_async(build.id) if revoke_secret_detection_token?(build)
      RequirementsManagement::ProcessRequirementsReportsWorker.perform_async(build.id)

      super
    end

    private

    def revoke_secret_detection_token?(build)
      ::Gitlab.com? &&
        ::Gitlab::CurrentSettings.secret_detection_token_revocation_enabled? &&
        secret_detection_vulnerability_found?(build)
    end

    def secret_detection_vulnerability_found?(build)
      build.pipeline.vulnerability_findings.secret_detection.any?
    end
  end
end
