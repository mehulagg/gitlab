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
        return {} unless project.feature_available?(:status_page)

        {
          'published-available' => 'true'
        }
      end
    end
  end
end
