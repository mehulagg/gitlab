# frozen_string_literal: true

module EE
  module Integrations
    module Test
      module ProjectService
        extend ::Gitlab::Utils::Override
        include ::Gitlab::Utils::StrongMemoize

        private

        override :data
        def data
          strong_memoize(:data) do
            next pipeline_events_data if integration.is_a?(::Integrations::Github)

            super
          end
        end
      end
    end
  end
end
