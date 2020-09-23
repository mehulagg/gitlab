# frozen_string_literal: true

module EE
  module Types
    module DeprecatedMutations
      extend ActiveSupport::Concern

      prepended do
        mount_mutation ::Mutations::Pipelines::RunDastScan, deprecated: { reason: 'Use DastOnDemandScanCreate', milestone: '13.4' }
        mount_aliased_mutation 'DismissVulnerability',
                             ::Mutations::Vulnerabilities::Dismiss,
                             deprecated: { reason: 'Use vulnerabilityDismiss', milestone: '13.5' }
      end
    end
  end
end
