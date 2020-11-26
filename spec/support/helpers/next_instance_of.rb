# frozen_string_literal: true

module NextInstanceOf
  def expect_next_instance_of(klass, *args, **kwargs)
    stub_new(expect(klass), *args, **kwargs) do |expectation|
      yield(expectation)
    end
  end

  def allow_next_instance_of(klass, *args, **kwargs)
    stub_new(allow(klass), *args, **kwargs) do |allowance|
      yield(allowance)
    end
  end

  private

  def stub_new(target, *new_args, **new_kwargs)
    receive_new = receive(:new)
    receive_new.with(*new_args, **new_kwargs) if new_args.any? || new_kwargs.any?

    target.to receive_new.and_wrap_original do |method, *original_args, **original_kwargs|
      method.call(*original_args, **original_kwargs).tap do |instance|
        yield(instance)
      end
    end
  end
end
