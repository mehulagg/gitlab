# frozen_string_literal: true

module Types
  class DastSiteProfileValidationStatusEnum < BaseEnum
    value 'PENDING_VALIDATION', description: 'Site validation process has not started'
    value 'INPROGRESS_VALIDATION', description: 'Site validation process is in progress'
    value 'PASSED_VALIDATION', description: 'Site validation process finished successfully'
    value 'FAILED_VALIDATION', description: 'Site validation process finished but failed'
  end
end
