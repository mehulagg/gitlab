# frozen_string_literal: true

module EE
  module Ci
    module PipelineBridgeStatusService
      extend ::Gitlab::Utils::Override

      override :execute
      def execute(pipeline)
        pipeline.downstream_bridges.each(&:inherit_status_from_upstream!)

        super
      end
    end
  end
end
