# frozen_string_literal: true

module Gitlab
  module ImportExport
    module Project
      module Sample
        class RelationFactory < Project::RelationFactory
          DATE_MODELS = %i[issues milestones].freeze

          def initialize(date_calculator:, **args)
            super(**args)

            @date_calculator = date_calculator
          end

          private

          def setup_models
            super

            # Override due date attributes in data hash for Sample Data templates
            # Dates are moved by taking the closest one to average and moving that (and rest around it) to the date of import
            override_date_attributes
          end

          def override_date_attributes
            return unless DATE_MODELS.include?(@relation_name)

            @relation_hash['start_date'] = @date_calculator.calculate_by_closest_date_to_average(@relation_hash['start_date'].to_time) unless @relation_hash['start_date'].nil?
            @relation_hash['due_date'] = @date_calculator.calculate_by_closest_date_to_average(@relation_hash['due_date'].to_time) unless @relation_hash['due_date'].nil?
          end
        end
      end
    end
  end
end
