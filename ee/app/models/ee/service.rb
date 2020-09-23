# frozen_string_literal: true

module EE
  module Service
    extend ActiveSupport::Concern

    EE_SERVICE_NAMES = %w[
      github
      jenkins
    ].freeze

    EE_DEV_SERVICE_NAMES = %w[
      gitlab_slack_application
    ].freeze

    class_methods do
      extend ::Gitlab::Utils::Override

      override :services_names
      def services_names
        super + ee_services_names
      end

      override :dev_services_names
      def dev_services_names
        return [] unless ::Gitlab.dev_env_or_com?

        super + ee_dev_services_names
      end

      private

      def ee_services_names
        EE_SERVICE_NAMES
      end

      def ee_dev_services_names
        EE_DEV_SERVICE_NAMES
      end
    end
  end
end
