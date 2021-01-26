# frozen_string_literal: true

module EE
  module Enums
    module Ci
      module Pipeline
        extend ActiveSupport::Concern

        class_methods do
          extend ::Gitlab::Utils::Override

          override :failure_reasons
          def failure_reasons
            super.merge(
              activity_limit_exceeded: 20,
              size_limit_exceeded: 21,
              job_activity_limit_exceeded: 22
            )
          end
        end
      end
    end
  end
end
