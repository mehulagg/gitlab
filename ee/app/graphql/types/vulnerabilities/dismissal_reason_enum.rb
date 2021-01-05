# frozen_string_literal: true

module Types
  module Vulnerabilities
    class DismissalReasonEnum < BaseEnum
      graphql_name 'VulnerabilityDismissalReason'
      description 'The dismissal reason of the Vulnerability'

      DISMISSAL_DESCRIPTIONS = {
        acceptable_risk: 'The likelihood of the Vulnerability occurring and its impact are deemed acceptable',
        false_positive: 'The Vulnerability was incorrectly identified as being present',
        mitigating_control: 'There is a mitigating control that eliminates the Vulnerability or makes its risk acceptable',
        used_in_tests: 'The Vulnerability is used in tests and does not pose an actual risk',
        not_applicable: 'Other reasons for dismissal'
      }.freeze

      ::Vulnerabilities::Feedback.dismissal_reasons.keys.each do |dismissal_reason|
        value dismissal_reason.to_s.upcase, value: dismissal_reason.to_s, description: DISMISSAL_DESCRIPTIONS[dismissal_reason.to_sym]
      end
    end
  end
end
