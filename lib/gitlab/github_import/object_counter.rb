# frozen_string_literal: true

# Count objects fetched or imported from Github in the context of the
# project being imported.
#
# When incrementing the counter within loops, to avoid sequential IO calls to Redis,
# the increment method can be used to wrap the loop and the counting will be done in
# a pipelined manner:
#
#   # This does 10 IO calls to Redis
#   10.times { Gitlab::Github::ObjectCounter.increment(project, :issue, :fetched) }
#
#   # This does one pipelined call to Redis
#   Gitlab::Github::ObjectCounter.increment(project, :issue, :fetched) do |counter|
#     10.times { counter.increment }
#   end
module Gitlab
  module GithubImport
    class ObjectCounter
      OPERATIONS = %w[fetched imported].freeze
      COUNTER_LIST_KEY = 'github-importer/object-counters-list/%{project}/%{operation}'
      COUNTER_KEY = 'github-importer/object-counter/%{project}/%{operation}/%{object_type}'
      CACHING = Gitlab::Cache::Import::Caching

      class PipelinedIncrement
        def initialize(key, redis)
          @redis = redis
          @key = key
        end

        def increment
          @redis.incr(@key)
        end
      end
      private_constant :PipelinedIncrement

      class << self
        def increment(project, object_type, operation, &block)
          validate_operation!(operation)

          counter_key = COUNTER_KEY % {
            project: project.id,
            operation: operation,
            object_type: object_type
          }

          add_counter_to_list(project, operation, counter_key)

          if block_given?
            CACHING.pipelined(counter_key) do |key, redis|
              yield(PipelinedIncrement.new(key, redis))
            end
          else
            CACHING.increment(counter_key)
          end
        end

        def summary(project)
          OPERATIONS.each_with_object({}) do |operation, result|
            result[operation] = {}

            CACHING
              .values_from_set(counter_list_key(project, operation))
              .sort
              .each do |counter|
                object_type = counter.split('/').last
                result[operation][object_type] = CACHING.read_integer(counter)
              end
          end
        end

        private

        def add_counter_to_list(project, operation, key)
          CACHING.set_add(counter_list_key(project, operation), key)
        end

        def counter_list_key(project, operation)
          COUNTER_LIST_KEY % { project: project.id, operation: operation }
        end

        def validate_operation!(operation)
          unless operation.to_s.presence_in(OPERATIONS)
            raise ArgumentError, "Operation must be #{OPERATIONS.join(' or ')}"
          end
        end
      end
    end
  end
end
