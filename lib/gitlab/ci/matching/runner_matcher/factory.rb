# frozen_string_literal: true

module Gitlab
  module Ci
    module Matching
      class RunnerMatcher
        class Factory
          include Gitlab::Utils::StrongMemoize

          def initialize(record)
            @record = record
          end

          def create
            return [] unless strategy

            strategy.build_from(@record)
          end

          private

          def strategy
            strong_memoize(:strategy) do
              strategies.find do |strategy|
                strategy.applies_to?(@record)
              end
            end
          end

          def strategies
            [RelationStrategy, RecordStrategy]
          end
        end
      end
    end
  end
end
