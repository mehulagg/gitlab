# frozen_string_literal: true

module EE
  module ReadonlyAbilities
    extend ActiveSupport::Concern

    READONLY_ABILITIES_EE = %i[
      admin_software_license_policy
      modify_auto_fix_setting
      create_test_case
    ].freeze

    READONLY_FEATURES_EE = %i[
      issue_board
      issue_link
      approvers
      vulnerability_feedback
      vulnerability
      feature_flag
      feature_flags_client
      iteration
    ].freeze

    class_methods do
      extend ::Gitlab::Utils::Override

      override :readonly_abilities
      def readonly_abilities
        (super + READONLY_ABILITIES_EE).freeze
      end

      override :readonly_features
      def readonly_features
        (super + READONLY_FEATURES_EE).freeze
      end
    end
  end
end
