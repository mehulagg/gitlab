# frozen_string_literal: true

class ElasticQueryNameInspector
  def initialize
    @buckets = []
  end

  def inspect(query)
    @buckets << query.deep_find_all("_name")
  end

  def reset!
    @buckets = []
  end

  def names
    @buckets.clone
  end

  def all_names
    @buckets.flatten
  end

  def has_named_query?(*names)
    names.all? { |name| all_names.include?(name) }
  end
end
