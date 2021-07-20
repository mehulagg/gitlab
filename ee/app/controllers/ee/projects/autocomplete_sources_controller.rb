# frozen_string_literal: true

module EE
  module Projects
    module AutocompleteSourcesController
      extend ActiveSupport::Concern

      prepended do
        feature_category :epics, [:epics]
        feature_category :vulnerability_management, [:vulnerabilities]
      end

      def epics
        return render_404 unless project.group.licensed_feature_available?(:epics)

        render json: autocomplete_service.epics
      end

      def vulnerabilities
        return render_404 unless project.feature_available?(:security_dashboard)

        render json: autocomplete_service.vulnerabilities
      end
    end
  end
end
