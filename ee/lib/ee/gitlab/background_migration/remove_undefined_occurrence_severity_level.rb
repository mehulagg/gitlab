# frozen_string_literal: true

module EE
  module Gitlab
    module BackgroundMigration
      module RemoveUndefinedOccurrenceSeverityLevel
        extend ::Gitlab::Utils::Override

        class Occurrence < ActiveRecord::Base
          include ::EachBatch

          self.table_name = 'vulnerability_occurrences'

          SEVERITY_LEVELS = {
            undefined: 0,
            unknown: 2
          }.with_indifferent_access.freeze

          enum severity: SEVERITY_LEVELS

          def self.undefined_severity
            where(severity: Occurrence.severities[:undefined])
          end
        end

        override :perform
        def perform(start_id, stop_id)
          Occurrence.undefined_severity
                    .where(id: start_id..stop_id)
                    .update_all(severity: Occurrence.severities[:unknown])
        end
      end
    end
  end
end
