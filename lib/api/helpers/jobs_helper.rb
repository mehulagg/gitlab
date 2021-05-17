# frozen_string_literal: true

module API
  module Helpers
    module JobsHelper
      def validate_current_authenticated_job!
        # current_authenticated_job will be nil if user is using
        # a valid authentication (like PRIVATE-TOKEN) that is not CI_JOB_TOKEN
        not_found!('Job') unless current_authenticated_job
      end
    end
  end
end
