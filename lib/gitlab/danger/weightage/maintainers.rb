# frozen_string_literal: true

weightage_path = File.expand_path('../weightage', __dir__)

if defined?(Rails)
  require_dependency(weightage_path)
else
  require_relative(weightage_path)
end

module Gitlab
  module Danger
    module Weightage
      class Maintainers
        def initialize(maintainers)
          @maintainers = maintainers
        end

        def execute
          maintainers.each_with_object([]) do |maintainer, weighted_maintainers|
            add_weighted_reviewer(weighted_maintainers, maintainer, BASE_REVIEWER_WEIGHT)
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
