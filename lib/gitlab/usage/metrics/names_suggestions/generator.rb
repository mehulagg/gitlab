# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module NamesSuggestions
        class Generator < ::Gitlab::UsageData
          class << self
            def generate(key_path)
              uncached_data.deep_stringify_keys.dig(*key_path.split('.'))
            end

            private

            def count(relation, column = nil, batch: true, batch_size: nil, start: nil, finish: nil)
              name_suggestion(column, relation, 'count')
            end

            def distinct_count(relation, column = nil, batch: true, batch_size: nil, start: nil, finish: nil)
              name_suggestion(column, relation, 'count_distinct', :distinct)
            end

            def redis_usage_counter
              "names_suggestions_for_redis_counters_are_not_supported_yet"
            end

            def redis_usage_data_totals(counter)
              counter.fallback_totals.transform_values { |_| "names_suggestions_for_redis_counters_are_not_supported_yet" }
            end

            def sum(relation, column, *rest)
              name_suggestion(column, relation, 'sum')
            end

            def estimate_batch_distinct_count(relation, column = nil, *rest)
              name_suggestion(column, relation, 'estimate_distinct_count')
            end

            def add(*args)
              "add_#{args.join('_and_')}"
            end

            def name_suggestion(column, relation, prefix, distinct = nil)
              parts = [prefix]
              target = parse_target(relation, column)

              if column
                parts << target
                parts << 'from'
              end

              source = parse_source(relation)
              constraints = parse_constraints(column, distinct, relation)

              if constraints.include?(source)
                parts << "<adjective describing: '#{constraints}'>"
              end

              parts << source
              parts.compact.join('_')
            end

            def parse_constraints(column, distinct, relation)
              connection = relation.connection
              RelationParsers::Constraints.new(connection).accept(arel(relation, column, distinct), collector(connection)).value
            end

            def parse_target(relation, column)
              if column.nil?
                "#{relation.table_name}.#{relation.primary_key}"
              elsif column.is_a?(Arel::Attribute)
                "#{column.relation.name}.#{column.name}"
              else
                column
              end
            end

            def parse_source(relation)
              relation.table_name
            end

            def collector(connection)
              Arel::Collectors::SubstituteBinds.new(connection, Arel::Collectors::SQLString.new)
            end

            def arel(relation, column, distinct)
              column ||= relation.primary_key

              if column.is_a?(Arel::Attribute)
                relation.select(column.count(distinct)).arel
              else
                relation.select(relation.all.table[column].count(distinct)).arel
              end
            end
          end
        end
      end
    end
  end
end
