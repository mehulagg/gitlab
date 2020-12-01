# frozen_string_literal: true

module EE
  module BuildDetailEntity
    extend ActiveSupport::Concern

    prepended do
      expose :runners do
        expose :quota, if: -> (*) { project.shared_runners_minutes_limit_enabled? } do
          expose :used do |runner|
            quota(project).total_minutes_used.to_i
          end

          expose :limit do |runner|
            quota(project).total_minutes.to_i
          end
        end
      end
    end

    private

    def quota(project)
      project.shared_runners_limit_namespace.ci_minutes_quota
    end
  end
end
