# frozen_string_literal: true

# This class allows to traverse a pipeline hierarchy where
# multiple pipelines are connected with each others through
# bridge jobs (e.g. multi-project or parent-child pipelines).
#
# Available options:
#  - `same_project: true` to traverse the hierarchy in the
#     context of parent-child pipelines. Use `false` for all
#     upstream/downstream pipelines regardless of the project
#
#  - `while_dependent: true` to traverse the hierarchy while
#     pipelines are connected via bridge jobs with `strategy:depend`
#     recursive search stops as soon as a bridge job doesn't use
#     `strategy:depend`.
#
#     Example: to return `base_and_descendants` of
#       * A -*> B ->> C -*> D : would return A and B but not C or D
#       * A ->> B -*> C -*> D : would return only A
#
#       NOTE: `-*>` denotes `strategy:depend`
#             `->>` denotes the default behavior (async execution).
module Gitlab
  module Ci
    class PipelineObjectHierarchy < ::Gitlab::ObjectHierarchy
      private

      def middle_table
        ::Ci::Sources::Pipeline.arel_table
      end

      def from_tables(cte)
        [objects_table, cte.table, middle_table] + optional_tables
      end

      def optional_tables
        return [] unless options[:while_dependent]

        ::Ci::Build.tables_from_builds_to_options
      end

      def parent_id_column(_cte)
        middle_table[:source_pipeline_id]
      end

      def ancestor_conditions(cte)
        middle_table[:source_pipeline_id].eq(objects_table[:id]).and(
          middle_table[:pipeline_id].eq(cte.table[:id])
        ).and(
          same_project_condition
        )
      end

      def descendant_conditions(cte)
        middle_table[:pipeline_id].eq(objects_table[:id]).and(
          middle_table[:source_pipeline_id].eq(cte.table[:id])
        ).and(
          same_project_condition
        ).and(
          dependent_condition
        )
      end

      def same_project_condition
        if options[:same_project]
          middle_table[:source_project_id].eq(middle_table[:project_id])
        else
          Arel.sql('TRUE')
        end
      end

      def dependent_condition
        if options[:while_dependent]
          middle_table[:source_job_id]
            .eq(::Ci::Build.arel_table[:id])
            .and(::Ci::Build.arel_with_strategy_depend_condition)
        else
          Arel.sql('TRUE')
        end
      end
    end
  end
end
