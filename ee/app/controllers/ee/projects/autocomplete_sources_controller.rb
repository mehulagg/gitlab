# frozen_string_literal: true

module EE
  module Projects
    module AutocompleteSourcesController
      extend ActiveSupport::Concern

      prepended do
        feature_category :epics, [:epics]
      end

      def epics
        return render_404 unless project.group.feature_available?(:epics)

        render json: autocomplete_service.epics
      end
    end
  end
end
