# frozen_string_literal: true

module Resolvers
  # Abstract class that will eliminate N+1 queries for collections of items
  # provided that:
  #
  # - the query can be uniquely determined by the object and the arguments
  # - the query is against an ApplicationRecord
  # - the model class includes FromUnion
  #
  # This comes at the cost of returning arrays, not relations, so we don't get
  # any pagination goodness. Consequently, this is only suitable for small-ish
  # result sets, and the field type must be a list type (i.e. `[MyType]`).
  #
  # Subclasses must implement:
  # - cache_key(**kwargs) -> Key
  # - model_class -> ApplicationRecord
  # - query_for(Key) -> Relation
  #
  class CachingArrayResolver < BaseResolver
    def resolve(**args)
      key = cache_key(**args)

      if cached = get(key)
        cached
      else
        ::Gitlab::Graphql::Lazy.new do
          fetch_all_uncached!

          # If nothing was found, then mark this with an empty result
          get(key, [])
        end
      end
    end

    # Override this to intercept the items once they are found
    # But always call super!
    def store(key, item)
      list = get(key, [])
      list << item
    end

    private

    # Fetch a cached value, or mark it for later fetching
    def get(key, or_else = nil)
      cache[key] ||= or_else
    end

    def fetch_all_uncached!
      keys = cache.each.select { |_k, v| v.nil? }.map(&:first).to_a
      return if keys.empty?

      queries = keys.map { |key| query_for(key) }

      model_class.from_union(tag(queries)).each do |item|
        i = item.union_member_idx
        store(keys[i], item)
      end
    end

    def cache
      context[self.class] ||= { results: {} }
      context[self.class][:results]
    end

    # Tag each row returned from each query with a the index of which query in
    # the union it comes from. This lets us map the results back to the cache key.
    def tag(queries)
      queries.each_with_index.map do |q, i|
        q.select(model_class.arel_table[Arel.star],
                 ::Arel::Nodes::SqlLiteral.new(i.to_s).as('union_member_idx'))
      end
    end
  end
end
