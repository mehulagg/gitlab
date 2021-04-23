# frozen_string_literal: true

module Admin
  class EmailService
    include ExclusiveLeaseGuard

    DEFAULT_LEASE_TIMEOUT = 10.minutes.to_i
    LEASE_KEY = 'admin/email_service'

    def initialize(recipients, subject, body)
      @recipients = recipients
      @subject = subject
      @body = body
    end

    def execute
      try_obtain_lease do
        AdminEmailsWorker.perform_async(recipients, subject, body)
      end
    end

    private

    attr_reader :recipients, :subject, :body

    def lease_key
      LEASE_KEY
    end

    def lease_timeout
      DEFAULT_LEASE_TIMEOUT
    end

    def lease_release?
      false
    end
  end
end
