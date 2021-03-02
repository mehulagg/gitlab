# frozen_string_literal: true

module Ci
  class UpdateBuildQueueService
    def execute(build, metrics = ::Gitlab::Ci::Queue::Metrics)
      tick_for(build, build.project.all_runners, metrics)
    end

    private

    def tick_for(build, runners, metrics)
      runners = runners.with_recent_runner_queue
      metrics.observe_active_runners(-> { runners.to_a.size })

      runners.each do |runner|
        metrics.increment_runner_tick(runner)

        if Feature.enabled?(:ci_reduce_queries_when_ticking_runner_queue, default_enabled: :yaml)
          runner.tick_runner_queue if runner.matches_build?(build)
        else
          runner.pick_build!(build)
        end
      end
    end
  end
end
