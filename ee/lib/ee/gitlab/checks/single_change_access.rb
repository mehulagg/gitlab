# frozen_string_literal: true

module EE
  module Gitlab
    module Checks
      module SingleChangeAccess
        extend ActiveSupport::Concern
        extend ::Gitlab::Utils::Override

        override :ref_level_checks
        def ref_level_checks
          super

          PushRuleCheck.new(self).validate!
        end
      end
    end
  end
end
