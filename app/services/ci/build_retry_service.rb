module Ci
  class BuildRetryService
    def initialize(build)
      @build = build
    end

    def execute
      try_retry if @build.auto_retry_allowed?
    end

    def try_retry
      Ci::Build.retry(@build, @build.user)
    rescue Gitlab::Access::AccessDeniedError => ex
      Gitlab::AppLogger.error "Unable to auto-retry job #{@build.id}: #{ex}"
    end
  end
end