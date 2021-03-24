# frozen_string_literal: true

module Ci
  module Minutes
    class EnforceQuotaService < ::BaseService
      def conditionally_execute_async
        # defined in EE
      end

      def execute
        # defined in EE
      end
    end
  end
end

Ci::Minutes::EnforceQuotaService.prepend_if_ee('EE::Ci::Minutes::EnforceQuotaService')
