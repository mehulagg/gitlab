# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Chain
          module Validate
            module External
              extend ::Gitlab::Utils::Override
              include ::Gitlab::Utils::StrongMemoize

              private

              delegate :namespace, to: :project

              override :validation_service_payload
              def validation_service_payload
                super.deep_merge(namespace_payload.merge(provisioning_group_payload))
              end

              def namespace_payload
                {
                  namespace: plan_and_trial_payload(namespace)
                }
              end

              def provisioning_group_payload
                return {} unless provisioning_group

                {
                  provisioning_group: plan_and_trial_payload(provisioning_group)
                }
              end

              def provisioning_group
                strong_memoize(:provisioning_group) do
                  current_user.provisioned_by_group
                end
              end

              def plan_and_trial_payload(group_or_namespace)
                {
                  plan: group_or_namespace.actual_plan_name,
                  trial: group_or_namespace.root_ancestor.trial_active?
                }
              end
            end
          end
        end
      end
    end
  end
end
