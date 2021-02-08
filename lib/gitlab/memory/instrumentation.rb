# frozen_string_literal: true

# This class uses a custom Ruby patch to allow
# a per-thread memory allocation tracking in a efficient manner
#
# This concept is currently tried to be upstreamed here:
# - https://github.com/ruby/ruby/pull/3978
module Gitlab
  module Memory
    class Instrumentation
      KEY_MAPPING = {
        total_allocated_objects: :mem_objects,
        total_malloc_bytes: :mem_bytes,
        total_mallocs: :mem_mallocs
      }.freeze

      MUTEX = Mutex.new

      def self.available?
        Thread.respond_to?(:trace_memory_allocations=) &&
          Thread.current.respond_to?(:memory_allocations)
      end

      # This method changes a global state
      def self.ensure_feature_flag!
        return unless available?

        enabled = Feature.enabled?(:trace_memory_allocations)
        return if enabled == Thread.trace_memory_allocations

        MUTEX.synchronize do
          # This enables or disables feature dynamically
          # based on a feature flag
          Thread.trace_memory_allocations = enabled
        end
      end

      def self.start_thread_memory_allocations
        return unless available?

        ensure_feature_flag!

        # it will return `nil` if disabled
        Thread.current.memory_allocations
      end

      # This method returns a hash with the following keys:
      # - mem_objects: a number of allocated heap slots (as reflected by GC)
      # - mem_mallocs: a number of malloc calls
      # - mem_bytes: a number of bytes allocated with a mallocs tied to heap slots
      def self.measure_thread_memory_allocations(previous)
        return unless available?
        return unless previous

        current = Thread.current.memory_allocations
        return unless current

        # calculate difference in a memory allocations
        previous.to_h do |key, value|
          [KEY_MAPPING.fetch(key), current[key].to_i - value]
        end
      end

      def self.with_memory_allocations
        previous = self.start_thread_memory_allocations
        yield
        self.measure_thread_memory_allocations(previous)
      end
    end
  end
end
