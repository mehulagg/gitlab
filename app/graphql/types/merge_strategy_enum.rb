# frozen_string_literal: true

module Types
  class MergeStrategyEnum < BaseEnum
    AutoMergeService::STRATEGIES.each do |strat|
      value strat.upcase, value: strat
    end
  end
end
