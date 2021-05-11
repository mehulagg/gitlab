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

                if current_user && !current_user.has_required_credit_card_to_run_pipelines?(project)
                  ::Gitlab::AppLogger.info(
                    message: 'Credit card required to be on file in order to create a pipeline',
                    project_path: project.full_path,
                    user_id: current_user.id,
                    plan: project.root_namespace.actual_plan_name
                  )

                  return error('Credit card required to be on file in order to create a pipeline', drop_reason: :user_not_verified)
                end

                super
              end
            end
          end
        end
      end
    end
  end
end
