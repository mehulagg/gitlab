# frozen_string_literal: true

module EE
  module Service
    extend ActiveSupport::Concern

    EE_COM_PROJECT_SPECIFIC_SERVICE_NAMES = %w[
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

        if ::Gitlab.com?
          services + EE_COM_PROJECT_SPECIFIC_SERVICE_NAMES
        else
          services
        end
      end
    end
  end
end
