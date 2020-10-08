# frozen_string_literal: true

module EE
  module Types
    module DeprecatedMutations
      extend ActiveSupport::Concern

      prepended do
        mount_mutation ::Mutations::Pipelines::RunDastScan, deprecated: { reason: 'Use DastOnDemandScanCreate', milestone: '13.4' }
      end
    end
  end
end
