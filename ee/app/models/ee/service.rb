# frozen_string_literal: true

module EE
  module Service
    extend ActiveSupport::Concern

    EE_DEV_OR_COM_PROJECT_SPECIFIC_SERVICE_NAMES = %w[
      gitlab_slack_application
    ].freeze

    EE_PROJECT_SPECIFIC_SERVICE_NAMES = %w[
      github
      jenkins
    ].freeze

    class_methods do
      extend ::Gitlab::Utils::Override

      override :project_specific_services_names
      def project_specific_services_names
        services = super + EE_PROJECT_SPECIFIC_SERVICE_NAMES

        if ::Gitlab.dev_env_or_com?
          services + EE_DEV_OR_COM_PROJECT_SPECIFIC_SERVICE_NAMES
        else
          services
        end
      end
    end
  end
end
