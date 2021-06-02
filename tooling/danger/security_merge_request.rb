# frozen_string_literal: true

module Tooling
  module Danger
    module SecurityMergeRequest
      ERROR_MESSAGE = <<~MSG
        Feature flags are discouraged from security merge requests.
        Read the [security documentation](https://gitlab.com/gitlab-org/release/docs/-/blob/master/general/security/utilities/feature_flags.md) for more information.
      MSG

      def check!
        return unless helper.security_mr?

        raise format(ERROR_MESSAGE) if feature_flag_included?
      end

      private

      def feature_flag_included?
        helper.all_changed_files.grep(%r{\A(ee/)?config/feature_flags/}).any?
      end
    end
  end
end
