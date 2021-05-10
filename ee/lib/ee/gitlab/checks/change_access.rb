# frozen_string_literal: true

module EE
  module Gitlab
    module Checks
      module ChangeAccess
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        override :ref_level_checks
        def ref_level_checks(oldrev, newrev, ref, skip_lfs_integrity_check: false)
          super

          PushRuleCheck.new(self).validate_change!(oldrev, newrev, ref)
        end
      end
    end
  end
end
