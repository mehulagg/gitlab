# frozen_string_literal: true

module EE
  module API
    module Features
      extend ActiveSupport::Concern

      prepended do
        helpers do
          extend ::Gitlab::Utils::Override

          override :log_release_created_audit_event
          def validate_licensed_name!(name)
            return unless License::PLANS_BY_FEATURE[name.to_sym]

            bad_request!(
              "The '#{name}' is a licensed feature name, " \
              "and thus it cannot be used as a feature flag name. " \
              "This can be overwritten with `force` parameter")
          end
        end
      end
    end
  end
end
