# frozen_string_literal: true

module EE
  module Projects
    module IncidentsHelper
      extend ::Gitlab::Utils::Override

      override :incidents_data
      def incidents_data(project, params)
        super.merge(
          incidents_data_ee(project)
        )
      end

      private

      def incidents_data_ee(project)
        {
          'published-available' => project.feature_available?(:status_page).to_s,
          'sla-feature-available' => ::IncidentManagement::IncidentSla.available_for?(project).to_s
        }
      end
    end
  end
end
