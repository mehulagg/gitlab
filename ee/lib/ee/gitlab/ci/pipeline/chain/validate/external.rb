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

              delegate :namespace, to: :project

              override :validation_service_payload
              def validation_service_payload
                super.deep_merge(
                  namespace: {
                    plan: namespace.actual_plan_name,
                    trial: namespace.root_ancestor.trial_active?
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
