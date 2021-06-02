# frozen_string_literal: true

require 'tooling/danger/feature_flag'

module Tooling
  module Danger
    module SecurityMergeRequest
      ERROR_MESSAGE = <<~MSG
        Feature flags are discouraged from security merge requests. See [here]() for for more information.
      MSG

      def check!
        return unless helper.security_mr?

        if feature_flag.feature_flag_files(change_type: :added).any?
          fail format(ERROR_MESSAGE)
        end
      end
    end
  end
end
