# frozen_string_literal: true

module EE
  module ResourceEvents
    module MergeIntoNotesService
      extend ActiveSupport::Concern
      extend ::Gitlab::Utils::Override

      EE_SYNTHETIC_NOTE_BUILDER_SERVICES = [
        SyntheticWeightNotesBuilderService,
        SyntheticIterationNotesBuilderService
      ].freeze

      private

      override :synthetic_notes
      def synthetic_notes
        super + ee_synthetic_notes
      end

      def ee_synthetic_notes
        EE_SYNTHETIC_NOTE_BUILDER_SERVICES.flat_map do |service|
          service.new(resource, current_user, params).execute
        end
      end
    end
  end
end
