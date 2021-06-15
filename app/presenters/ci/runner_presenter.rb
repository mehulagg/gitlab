# frozen_string_literal: true

module Ci
  class RunnerPresenter < Gitlab::View::Presenter::Delegated
    include Gitlab::Utils::StrongMemoize

    BUILD_COUNT_LIMIT = 1000

    presents :runner

    def job_count
      return 0 unless can?(current_user, :read_build)

      strong_memoize(:job_count) do
        runner.builds.limit(BUILD_COUNT_LIMIT).count
      end
    end

    def project_count
      strong_memoize(:project_count) do
        runner.projects.count(:all)
      end
    end
  end
end
