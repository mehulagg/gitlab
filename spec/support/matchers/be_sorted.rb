# frozen_string_literal: true

# Assert that this collection is sorted by argument and order
#
# By default, this checks that the collection is sorted ascending
# but you can check order by specific field and order by passing
# them, eg:
#
# ```
# expect(collection).to be_sorted(:field, :desc)
# ```
RSpec::Matchers.define :be_sorted do |on = :itself, order = :asc|
  def by(&blk)
    @comparator = blk
    self
  end

  def asc
    @direction = :asc
    self
  end

  def desc
    @direction = :desc
    self
  end

  def format_with(proc)
    @format_with = proc
    self
  end

  define_method :comparator do
    @comparator || on
  end

  define_method :descending? do
    (@direction || order.to_sym) == :desc
  end

  def order(items)
    descending? ? items.reverse : items
  end

  def sort(items)
    items.sort_by(&comparator)
  end

  match do |actual|
    next true unless actual.present? # empty collection is sorted

    actual = actual.to_a if actual.respond_to?(:to_a) && !actual.respond_to?(:sort_by)

    @got = actual
    @expected = order(sort(actual))

    @expected == actual
  end

  def failure_message
    "Expected #{show(@expected)}, got #{show(@got)}"
  end

  def show(things)
    if @format_with
      things.map(&@format_with)
    else
      things
    end
  end
end
