# frozen_string_literal: true

module Gitlab
  module Danger
    module Reviewers
      CAPACITY_MULTIPLIER = 2 # change this number to change what it means to be a reduced capacity reviewer 1/this number
      REVIEWER_WEIGHT = 1
    end
  end
end
