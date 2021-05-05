# frozen_string_literal: true

module Ci
  class LazyFilteredBuilds
    BATCH_SIZE = 1000

    def initialize(scope, inner_scope, sort_by_lambda:)
      @scope = scope
      @inner_scope = inner_scope
      @sort_by_lambda = sort_by_lambda
    end

    def to_a
      @to_a ||= sorted_records
    end

    def pluck(attr)
      to_a.map(&attr)
    end

    # Proxy the method calls to inner_scope so they will be executed on the batched query
    [:merge, :matches_tag_ids].each do |method|
      define_method method do |*args|
        instance_variable_set('@inner_scope', instance_variable_get('@inner_scope').public_send(method, *args)) # rubocop: disable GitlabSecurity/PublicSend

        self
      end
    end

    private

    attr_reader :scope, :inner_scope, :sort_by_lambda

    def sorted_records
      records = []

      scope.each_batch(of: BATCH_SIZE) do |query|
        records.concat(query.merge(inner_scope).to_a)
      end

      records.sort_by(&sort_by_lambda)
    end
  end
end
