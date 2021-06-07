# frozen_string_literal: true

module AuditEvents
  class ReleaseArtifactsDownloadedAuditEventService < ReleaseAuditEventService
    def message
      'Repository External Resource Download Started'
    end
  end
end
