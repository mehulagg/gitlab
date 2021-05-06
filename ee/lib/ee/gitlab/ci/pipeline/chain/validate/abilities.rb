# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Chain
          module Validate
            module Abilities
              extend ::Gitlab::Utils::Override

              override :perform!
              def perform!
                # We check for `builds_enabled?` here so that this error does
                # not get produced before the "pipelines are disabled" error.
                if project.builds_enabled? &&
                    (command.allow_mirror_update && !project.mirror_trigger_builds?)
                  return error('Pipeline is disabled for mirror updates')
                end

                if missing_required_credit_card?
                  return error('Credit card required to be on file in order to create a pipeline', drop_reason: :user_not_verified)
                end

                super
              end

              def missing_required_credit_card?
                return false unless ::Gitlab.com?
                return false if current_user.credit_card_validated_at.present?

                free_plan? || trial_plan?
              end

              def free_plan?
                return false unless ::Feature.enabled?(:ci_require_credit_card_on_free_plan, project, default_enabled: :yaml)

                root_namespace.free_plan?
              end

              def trial_plan?
                return false unless ::Feature.enabled?(:ci_require_credit_card_on_trial_plan, project, default_enabled: :yaml)

                root_namespace.trial?
              end

              def root_namespace
                @root_namespace ||= project.root_namespace
              end
            end
          end
        end
      end
    end
  end
end
