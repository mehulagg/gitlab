# frozen_string_literal: true

module EE
  module Admin
    module HealthCheckController
      extend ::Gitlab::Utils::Override
      include ::Gitlab::Utils::StrongMemoize

      private

      override :checks
      def checks
        strong_memoize(:checks) do
          base_checks = super
          base_checks << 'geo' if ::Gitlab::Geo.secondary?

          base_checks
        end
      end
    end
  end
end
