# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Status
        module Build
          module Failed
            extend ActiveSupport::Concern

            prepended do
              EE_REASONS = const_get(:REASONS, false).merge(
                protected_environment_failure: 'protected environment failure',
                upstream_bridge_project_not_found: 'upstream project could not be found',
                insufficient_upstream_permissions: 'no permissions to read upstream project'
              ).freeze
              EE::Gitlab::Ci::Status::Build::Failed.private_constant :EE_REASONS
            end

            class_methods do
              extend ::Gitlab::Utils::Override

              override :reasons
              def reasons
                EE_REASONS
              end
            end
          end
        end
      end
    end
  end
end
