# frozen_string_literal: true

module Operations
  module FeatureFlags
    class StrategyUserList < NamespaceShard
      self.table_name = 'operations_strategies_user_lists'

      belongs_to :strategy
      belongs_to :user_list
    end
  end
end
