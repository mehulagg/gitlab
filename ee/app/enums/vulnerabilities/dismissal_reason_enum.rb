# frozen_string_literal: true

module Vulnerabilities
  module DismissalReasonEnum
    extend DeclarativeEnum

    key :dismissal_reason
    name 'VulnerabilityDismissalReason'
    description 'The dismissal reason of the Vulnerability'

    define do
      acceptable_risk value: 0, description: _('The vulnerability is known, and has not been remediated or mitigated, but is considered to be an acceptable business risk.')
      false_positive value: 1, description: _('An error in reporting in which a test result incorrectly indicates the presence of a vulnerability in a system when the vulnerability is not present.')
      mitigating_control value: 2, description: _('A management, operational, or technical control (that is, safeguard or countermeasure) employed by an organization that provides equivalent or comparable protection for an information system.')
      used_in_tests value: 3, description: _('The finding is not a vulnerability because it is part of a test or is test data.')
      not_applicable value: 4, description: _('The vulnerability is known, and has not been remediated or mitigated, but is considered to be in a part of the application that will not be updated.')
    end
  end
end
