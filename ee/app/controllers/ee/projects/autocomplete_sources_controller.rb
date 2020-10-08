# frozen_string_literal: true

module EE
  module Projects
    module AutocompleteSourcesController
      extend ActiveSupport::Concern

      def epics
        return render_404 unless project.group.feature_available?(:epics)

        render json: autocomplete_service.epics
      end

      def vulnerabilities
        return render_404 unless project.feature_available?(:security_dashboard)

        render json: autocomplete_service.vulnerabilities
      end
    end
  end
end
