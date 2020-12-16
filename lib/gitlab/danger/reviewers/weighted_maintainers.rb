# frozen_string_literal: true

require_relative '../reviewers'

module Gitlab
  module Danger
    module Reviewers
      class WeightedMaintainers
        def initialize(maintainers)
          @maintainers = maintainers
        end

        def execute
          maintainers.each_with_object([]) do |maintainer, weighted_maintainers|
            add_weighted_reviewer(weighted_maintainers, maintainer, REVIEWER_WEIGHT)
          end
        end

        private

        attr_reader :maintainers

        def add_weighted_reviewer(reviewers, reviewer, weight)
          if reviewer.reduced_capacity
            reviewers.fill(reviewer, reviewers.size, weight)
          else
            reviewers.fill(reviewer, reviewers.size, weight * CAPACITY_MULTIPLIER)
          end
        end
      end
    end
  end
end
