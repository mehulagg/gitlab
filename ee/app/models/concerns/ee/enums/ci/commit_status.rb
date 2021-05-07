# frozen_string_literal: true

module EE
  module Enums
    module Ci
      module CommitStatus
        extend ActiveSupport::Concern

        class_methods do
          extend ::Gitlab::Utils::Override

          override :failure_reasons
          def failure_reasons
            super.merge(protected_environment_failure: 1_000,
                        upstream_bridge_project_not_found: 1_004,
                        insufficient_upstream_permissions: 1_005)
          end
        end
      end
    end
  end
end
