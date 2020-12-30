# frozen_string_literal: true

module MemberPermissions
  class ExportWorker
    include ApplicationWorker
    include ::Gitlab::ExclusiveLeaseHelpers

    sidekiq_options dead: false

    # feature_category :vulnerability_management to do: verify
    worker_resource_boundary :cpu

    idempotent! # to do: verify

    sidekiq_retries_exhausted do |job|
      Vulnerabilities::Export.find_by_id(job['args'].last).failed!
    end

    def perform(current_user_id, upload_id)
      upload = UserPermissionExportUpload.find_by_id(upload_id)
      current_user = User.find_by_id(current_user_id)
      return unless upload

      ::MemberPermissionExport::ExportService.new(current_user, upload).export
    end
  end
end
