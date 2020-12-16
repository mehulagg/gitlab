# frozen_string_literal: true

require_relative '../reviewers'

module Gitlab
  module Danger
    module Reviewers
      class WeightedReviewers
        HUNGRY_WEIGHT = 2
        TRAINTAINER_WEIGHT = 3

        def initialize(reviewers, traintainers)
          @reviewers = reviewers
          @traintainers = traintainers
        end

        def execute
          # TODO: take CODEOWNERS into account?
          # https://gitlab.com/gitlab-org/gitlab/issues/26723

          # Make hungry traintainers have 4x the chance to be picked as a reviewer
          # Make traintainers have 3x the chance to be picked as a reviewer
          # Make hungry reviewers have 2x the chance to be picked as a reviewer

          weighted_reviewers + weighted_traintainers
        end

        private

        attr_reader :reviewers, :traintainers

        def weighted_reviewers
          reviewers.each_with_object([]) do |reviewer, total_reviewers|
            add_weighted_reviewer(total_reviewers, reviewer, REVIEWER_WEIGHT)
          end
        end

        def weighted_traintainers
          traintainers.each_with_object([]) do |reviewer, total_traintainers|
            add_weighted_reviewer(total_traintainers, reviewer, TRAINTAINER_WEIGHT)
          end
        end

        def add_weighted_reviewer(reviewers, reviewer, weight)
          if reviewer.reduced_capacity
            reviewers.fill(reviewer, reviewers.size, weight)
          elsif reviewer.hungry
            reviewers.fill(reviewer, reviewers.size, weight * CAPACITY_MULTIPLIER * HUNGRY_WEIGHT)
          else
            reviewers.fill(reviewer, reviewers.size, weight * CAPACITY_MULTIPLIER)
          end
        end
      end
    end
  end
end
