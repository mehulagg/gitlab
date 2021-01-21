# frozen_string_literal: true

module Vulnerabilities
  module DismissalReasonEnum
    extend DeclarativeEnum

    key :dismissal_reason
    name 'VulnerabilityDismissalReason'
    description 'The dismissal reason of the Vulnerability'

    define do
      acceptable_risk value: 0, description: 'The likelihood of the Vulnerability occurring and its impact are deemed acceptable'
      false_positive value: 1, description: 'The Vulnerability was incorrectly identified as being present'
      mitigating_control value: 2, description: 'There is a mitigating control that eliminates the Vulnerability or makes its risk acceptable'
      used_in_tests value: 3, description: 'The Vulnerability is used in tests and does not pose an actual risk'
      not_applicable value: 4, description: 'Other reasons for dismissal'
    end
  end
end
