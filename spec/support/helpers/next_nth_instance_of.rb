# frozen_string_literal: true

module NextNthInstanceOf
  METHOD_NAME_PATTERN = /allow_next_((?:(?:\d)*(?<!1)(?:1st|2nd|3rd))|\d+th)_instance_of/

  def method_missing(method_name, *args, &block)
    match_data = method_name.to_s.match(METHOD_NAME_PATTERN)

    return super unless match_data

    n = match_data.captures.first[0..-3].to_i

    allow_next_nth_instance_of(n, *args, &block)
  end

  def allow_next_nth_instance_of(n, klass, *new_args, &blk)
    stub_new(allow(klass), nil, false, *new_args, &blk)
  end

  private

  def stub_new(target, number, ordered = false, *new_args, &blk)
    receive_new = receive(:new)
    receive_new.ordered if ordered
    receive_new.exactly(number).times if number
    receive_new.with(*new_args) if new_args.any?

    target.to receive_new.and_wrap_original do |method, *original_args|
      method.call(*original_args).tap(&blk)
    end
  end
end
