# frozen_string_literal: true

module Types
  module Vulnerabilities
    class DismissalReasonEnum < BaseEnum
      graphql_name 'VulnerabilityDismissalReason'
      description 'The dismissal reason of the Vulnerability'

      ::Vulnerabilities::Feedback.dismissal_reasons.keys.each do |dismissal_reason|
        value dismissal_reason.to_s.upcase, value: dismissal_reason.to_s
      end
    end
  end
end
