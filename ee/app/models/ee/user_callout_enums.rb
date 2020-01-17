# frozen_string_literal: true

module EE
  module UserCalloutEnums
    extend ActiveSupport::Concern

    class_methods do
      extend ::Gitlab::Utils::Override

      override :feature_names
      def feature_names
        super.merge(
          gold_trial: 4,
          geo_enable_hashed_storage: 5,
          geo_migrate_hashed_storage: 6,
          canary_deployment: 7,
          gold_trial_billings: 8,
          threat_monitoring_info: 11,
          # Bump this value to trigger new account recovery check
          # https://gitlab.com/gitlab-org/gitlab/issues/30065
          # id Format: 1YYMM"
          account_recovery_regular_check: 12002
        )
      end
    end
  end
end
