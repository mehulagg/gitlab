# frozen_string_literal: true

module Types
  class MergeStrategyEnum < BaseEnum
    AutoMergeService.all_strategies_ordered_by_preference.each do |strat|
      value strat.upcase, value: strat
    end
  end
end
