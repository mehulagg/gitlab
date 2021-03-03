# frozen_string_literal: true

module EE
  module Gitlab
    module Ci
      module Pipeline
        module Chain
          module Limit
            module Activity
              extend ::Gitlab::Utils::Override
              include ::Gitlab::Ci::Pipeline::Chain::Helpers
              include ::Gitlab::OptimisticLocking

              attr_reader :limit
              private :limit

              def initialize(*)
                super

                @limit = Pipeline::Quota::Activity
                  .new(project.namespace, pipeline.project)
              end

              override :perform!
              def perform!
                return unless limit.exceeded?

                retry_optimistic_lock(pipeline, name: 'ci_pipeline_chain_limit_activity') do
                  pipeline.drop!(:activity_limit_exceeded)
                  limit.log_error!(project_id: project.id, plan: project.actual_plan_name)
                end
              end

              override :break?
              def break?
                limit.exceeded?
              end
            end
          end
        end
      end
    end
  end
end
