# frozen_string_literal: true

module EE
  module Types
    module DeprecatedMutations
      extend ActiveSupport::Concern

      prepended do
        mount_aliased_mutation 'DismissVulnerability',
                             ::Mutations::Vulnerabilities::Dismiss,
                             deprecated: { reason: 'Use vulnerabilityDismiss', milestone: '13.5' }
        mount_aliased_mutation 'RevertVulnerabilityToDetected',
                             ::Mutations::Vulnerabilities::RevertToDetected,
                             deprecated: { reason: 'Use vulnerabilityRevertToDetected', milestone: '13.5' }
      end
    end
  end
end
