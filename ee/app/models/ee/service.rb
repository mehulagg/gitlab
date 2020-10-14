# frozen_string_literal: true

module EE
  module Service
    extend ActiveSupport::Concern

    EE_SERVICE_NAMES = %w[
      github
      jenkins
    ].freeze

    EE_PROJECT_SPECIFIC_SERVICE_NAMES = %w[
      gitlab_slack_application
    ].freeze

    class_methods do
      extend ::Gitlab::Utils::Override

      override :services_names
      def services_names
        super + EE_SERVICE_NAMES
      end

      override :project_specific_services_names
      def project_specific_services_names
        return [] unless ::Gitlab.dev_env_or_com?

        EE_PROJECT_SPECIFIC_SERVICE_NAMES
      end
    end
  end
end
