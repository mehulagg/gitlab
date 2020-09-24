# frozen_string_literal: true

module Gitlab
  module SidekiqMiddleware
    module DuplicateJobs
      module Strategies
        # This strategy will never deduplicate a job
        class None
          def initialize(_duplicate_job)
          end

          def schedule(_job)
            yield
          end

          def perform(_job)
            yield
          end
        end
      end
    end
  end
end
