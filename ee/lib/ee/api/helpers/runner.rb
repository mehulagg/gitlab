# frozen_string_literal: true

module EE
  module API
    module Helpers
      module Runner
        extend ::Gitlab::Utils::Override

        override :current_job
        def current_job
          id = params[:id]

          if id
            ::Gitlab::Database::LoadBalancing::RackMiddleware
              .stick_or_unstick(env, :build, id)
          end

          super
        end

        override :current_runner
        def current_runner
          token = params[:token]

          if token
            ::Gitlab::Database::LoadBalancing::RackMiddleware
              .stick_or_unstick(env, :runner, token)
          end

          super
        end

        override :track_ci_minutes_usage!
        def track_ci_minutes_usage!(build, runner)
          ::Ci::Minutes::TrackLiveConsumptionService.new(build).execute
        end
      end
    end
  end
end
