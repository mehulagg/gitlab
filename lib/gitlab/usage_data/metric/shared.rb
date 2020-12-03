# frozen_string_literal: true

module Gitlab
  class UsageData
    class Metric
      module Shared
        PARAMS = %i[
          name
          description
          default_generation
          full_path
          milestone
          introduced_by_url
          group
          time_frame
          type
          data_source
          distribution
          tier
        ].freeze
      end
    end
  end
end
