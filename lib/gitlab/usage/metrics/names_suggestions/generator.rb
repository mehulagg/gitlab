# frozen_string_literal: true

module Gitlab
  module Usage
    module Metrics
      module NamesSuggestions
        class Generator < ::Gitlab::UsageData
          FREE_TEXT_METRIC_NAME = "<please fill metric name>"

          module NamesSuggestionsInterceptor
            def count(relation, column = nil, batch: true, batch_size: nil, start: nil, finish: nil)
              name_suggestion(column: column, relation: relation, prefix: 'count')
            end

            def distinct_count(relation, column = nil, batch: true, batch_size: nil, start: nil, finish: nil)
              name_suggestion(column: column, relation: relation, prefix: 'count_distinct', distinct: :distinct)
            end

            def redis_usage_counter
              FREE_TEXT_METRIC_NAME
            end

            def alt_usage_data(*)
              FREE_TEXT_METRIC_NAME
            end

            def redis_usage_data_totals(counter)
              counter.fallback_totals.transform_values { |_| FREE_TEXT_METRIC_NAME}
            end

            def sum(relation, column, *rest)
              name_suggestion(column: column, relation: relation, prefix: 'sum')
            end

            def estimate_batch_distinct_count(relation, column = nil, *rest)
              name_suggestion(column: column, relation: relation, prefix: 'estimate_distinct_count')
            end

            def add(*args)
              "add_#{args.join('_and_')}"
            end

            def name_suggestion(relation:, column: nil, prefix: nil, distinct: nil)
              parts = [prefix]
              arel_column = arelize_column(relation, column)

              # nil as column indicates that the counting would use fallback value of primary key.
              # Because counting primary key from relation is the conceptual equal to counting all
              # records from given relation, in order to keep name suggestion more condensed
              # primary key column is skipped.
              # eg: SELECT COUNT(id) FROM issues would translate as count_issues and not
              # as count_id_from_issues since it does not add more information to the name suggestion
              if arel_column != Arel::Table.new(relation.table_name)[relation.primary_key]
                parts << arel_column.name
                parts << 'from'
              end

              arel = arel_query(relation: relation, column: arel_column, distinct: distinct)
              constraints = parse_constraints(relation: relation, arel: arel)

              # In some cases due to performance reasons metrics are instrumented with joined relations
              # where relation listed in FROM statement is not the one that includes counted attribute
              # in such situations to make name suggestion more intuitive source should be inferred based
              # on the relation that provide counted attribute
              # EG: SELECT COUNT(deployments.environment_id) FROM clusters
              #       JOIN deployments ON deployments.cluster_id = cluster.id
              # should be translated into:
              #   count_environment_id_from_deployments_with_clusters
              # instead of
              #   count_environment_id_from_clusters_with_deployments
              actual_source = parse_source(relation, arel_column)

              if constraints.include?(actual_source)
                parts << "<adjective describing: '#{constraints}'>"
              end

              parts << actual_source
              parts += process_joined_relations(actual_source, arel, relation)
              parts.compact.join('_')
            end

            def parse_constraints(relation:, arel:)
              connection = relation.connection
              ::Gitlab::Usage::Metrics::NamesSuggestions::RelationParsers::Constraints
                .new(connection)
                .accept(arel, collector(connection))
                .value
            end

            # TODO: joins with `USING` keyword
            def process_joined_relations(actual_source, arel, relation)
              joins = parse_joins(connection: relation.connection, arel: arel)
              return [] unless joins.any?

              sources = [relation.table_name, *joins.map { |join| join[:source] }]
              joins = extract_joins_targets(joins, sources)

              relations = if actual_source != relation.table_name
                            build_relations_tree(joins + [{ source: relation.table_name }], actual_source)
                          else
                            # in case where counter attribute comes from joined relations, the relations
                            # diagram has to be built bottom up, thus source and target are reverted
                            build_relations_tree(joins + [{ source: relation.table_name }], actual_source, source_key: :target, target_key: :source)
                          end

              collect_join_parts(relations[actual_source])
            end

            def parse_joins(connection:, arel:)
              ::Gitlab::Usage::Metrics::NamesSuggestions::RelationParsers::Joins
                .new(connection)
                .accept(arel)
            end

            def extract_joins_targets(joins, sources)
              joins.map do |join|
                source_regex = /(#{join[:source]})\.(\w+_)*id/i

                tables_except_src = (sources - [join[:source]]).join('|')
                target_regex = /(?<target>#{tables_except_src})\.(\w+_)*id/i

                join_cond_regex = /(#{source_regex}\s+=\s+#{target_regex})|(#{target_regex}\s+=\s+#{source_regex})/i
                matched = join_cond_regex.match(join[:constraints])

                join[:target] = matched[:target] if matched
                join
              end
            end

            def build_relations_tree(joins, parent, source_key: :source, target_key: :target)
              return [] if joins.blank?

              tree = {}
              tree[parent] = []

              joins.each do |join|
                if join[source_key] == parent
                  tree[parent] << build_relations_tree(joins - [join], join[target_key], source_key: source_key, target_key: target_key)
                end
              end
              tree
            end

            def collect_join_parts(joined_relations, parts = [], conjunctions = %w[with having including].cycle)
              conjunction = conjunctions.next
              joined_relations.each do |subtree|
                subtree.each do |parent, children|
                  parts << "<#{conjunction}>"
                  parts << parent
                  collect_join_parts(children, parts, conjunctions)
                end
              end
              parts
            end

            def arelize_column(relation, column)
              case column
              when Arel::Attribute
                column
              when NilClass
                Arel::Table.new(relation.table_name)[relation.primary_key]
              when String
                if column.include?('.')
                  table, col = column.split('.')
                  Arel::Table.new(table)[col]
                else
                  Arel::Table.new(relation.table_name)[column]
                end
              when Symbol
                arelize_column(relation, column.to_s)
              end
            end

            def parse_source(relation, column)
              column.relation.name || relation.table_name
            end

            def collector(connection)
              Arel::Collectors::SubstituteBinds.new(connection, Arel::Collectors::SQLString.new)
            end

            def arel_query(relation:, column: nil, distinct: nil)
              column ||= relation.primary_key

              if column.is_a?(Arel::Attribute)
                relation.select(column.count(distinct)).arel
              else
                relation.select(relation.all.table[column].count(distinct)).arel
              end
            end
          end

          class << self
            def generate(key_path)
              # uncached_data.deep_stringify_keys.dig(*key_path.split('.'))
              definition = Gitlab::Usage::MetricDefinition.find_by(key_path: key_path)
              instrumentation_class = definition.attributes[:instrumentation_class].constantize
              Class.new(instrumentation_class) do
                include NamesSuggestionsInterceptor
              end.new.value
            end

            # private

          end
        end
      end
    end
  end
end
