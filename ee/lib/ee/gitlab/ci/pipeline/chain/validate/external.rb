# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Chain
          module Validate
            module External
              extend ::Gitlab::Utils::Override

              private

              override :validation_service_payload
              def validation_service_payload(pipeline, stages_attributes)
                super.deep_merge(
                  namespace: {
                    plan: pipeline.project.namespace.actual_plan_name,
                    trial: pipeline.project.namespace.trial_active?
                  }
                )
              end
            end
          end
        end
      end
    end
  end
end
