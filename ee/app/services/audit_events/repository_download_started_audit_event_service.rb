# frozen_string_literal: true

module AuditEvents
  class RepositoryDownloadStartedAuditEventService < CustomAuditEventService
    def initialize(author, entity, ip_address)
      super(author, entity, ip_address, 'Repository Download Started')
    end
  end
end
