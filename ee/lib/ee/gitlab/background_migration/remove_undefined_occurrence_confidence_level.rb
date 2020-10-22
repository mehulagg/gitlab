# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      module RemoveUndefinedOccurrenceConfidenceLevel
        extend ::Gitlab::Utils::Override

        class Occurrence < ActiveRecord::Base
          include ::EachBatch

          self.table_name = 'vulnerability_occurrences'

          CONFIDENCE_LEVELS = {
            undefined: 0,
            unknown: 2
          }.with_indifferent_access.freeze

          enum confidence: CONFIDENCE_LEVELS

          def self.undefined_confidence
            where(confidence: Occurrence.confidences[:undefined])
          end
        end

        override :perform
        def perform(start_id, stop_id)
          Occurrence.undefined_confidence
                    .where(id: start_id..stop_id)
                    .update_all(confidence: Occurrence.confidences[:unknown])
        end
      end
    end
  end
end
