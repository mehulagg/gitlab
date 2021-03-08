# frozen_string_literal: true

module Types
  module Subscriptions
    class PlanTagType < BaseEnum
      description "An enum that represents either a Plan or group of Plans. "\
          "These are derived from the constants in models/Plan.rb. For example, 'GITLAB_EE_STARTER_1_YEAR_PLAN'"

      value 'CI_1000_MINUTES_PLAN', 'Ci 1000 minutes plan.'
    end
  end
end
