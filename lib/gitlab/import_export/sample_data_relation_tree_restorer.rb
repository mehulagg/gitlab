# frozen_string_literal: true

module Gitlab
  module ImportExport
    class SampleDataRelationTreeRestorer < RelationTreeRestorer
      DUE_DATE_MODELS = %i[issues milestones].freeze

      private

      def build_relation(relation_key, relation_definition, data_hash)
        # Override due date attributes for Sample Data template
        override_due_date_attributes!(relation_key, data_hash)
        super
      end

      def override_due_date_attributes!(relation_key, data_hash)
        return unless DUE_DATE_MODELS.include?(relation_key.to_sym) && !data_hash['due_date'].nil?

        data_hash['due_date'] = due_date_calculator.calculate(data_hash['due_date'].to_time)
      end

      def due_dates
        due_dates = []

        unless relation_reader.legacy?
          due_dates += DUE_DATE_MODELS.map do |tag|
            relation_reader.consume_relation(@importable_path, tag).map { |model| model.first['due_date'] }.tap do
              # Hack to clear consumed relations, so we could read them again
              consumed_relations = relation_reader.instance_variable_get(:@consumed_relations)
              consumed_relations.delete("#{@importable_path}/#{tag}")
            end
          end
          due_dates.flatten!
          due_dates.compact!
        end

        due_dates
      end

      def due_date_calculator
        @due_date_calculator ||= Gitlab::ImportExport::DueDateCalculator.new(due_dates)
      end
    end
  end
end
