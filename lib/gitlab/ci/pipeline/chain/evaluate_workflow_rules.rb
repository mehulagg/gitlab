# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        class EvaluateWorkflowRules < Chain::Base
          include ::Gitlab::Utils::StrongMemoize
          include Chain::Helpers

          def perform!
            if workflow_passed?
              apply_rules
            else
              error('Pipeline filtered out by workflow rules.')
            end
          end

          def break?
            @pipeline.errors.any? || @pipeline.persisted?
          end

          private

          def apply_rules
            @pipeline.assign_attributes(rules_attributes)
          end

          def rules_attributes
            workflow_rules_result.pipeline_attributes(yaml_variables: @pipeline.yaml_variables)
          end

          def workflow_passed?
            workflow_rules_result.pass?
          end

          def workflow_rules_result
            strong_memoize(:workflow_rules_result) do
              workflow_rules.evaluate(@pipeline, global_context)
            end
          end

          def workflow_rules
            Gitlab::Ci::Build::Rules.new(
              workflow_config[:rules], default_when: 'always')
          end

          def global_context
            Gitlab::Ci::Build::Context::Global.new(
              @pipeline, yaml_variables: workflow_config[:yaml_variables])
          end

          def has_workflow_rules?
            workflow_config[:rules].present?
          end

          def workflow_config
            @command.yaml_processor_result.workflow_attributes || {}
          end
        end
      end
    end
  end
end
