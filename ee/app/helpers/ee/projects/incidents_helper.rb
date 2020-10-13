# frozen_string_literal: true

module EE
  module Projects
    module IncidentsHelper
      extend ::Gitlab::Utils::Override

      override :incidents_data
      def incidents_data(project, params)
        super.merge(
          incidents_data_published_available(project)
        )
      end

      private

      def incidents_data_published_available(project)
        {
          'published-available' => project.feature_available?(:status_page),
          'incident-sla-available' => (::Feature.enabled?(:incident_sla_dev, @project) && project.feature_available?(:incident_sla)).to_s
        }
      end
    end
  end
end
