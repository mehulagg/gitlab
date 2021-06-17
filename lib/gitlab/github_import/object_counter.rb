# frozen_string_literal: true

# - project
# - operation: FETCH, IMPORT
# - object_type: pull_request, issue, note, etc
module Gitlab
  module GithubImport
    class ObjectCounter
      OPERATIONS = %i[fetched imported].freeze
      COUNTER_LIST_KEY = 'github-importer/object-counters-list/%{project}/%{operation}'
      COUNTER_KEY = 'github-importer/object-counter/%{project}/%{operation}/%{object_type}'

      class << self
        def increment(project, object_type, operation)
          validate_operation!(operation)

          counter_key = COUNTER_KEY % { project: project.id, operation: operation, object_type: object_type }

          add_counter_to_list(project, operation, counter_key)

          Gitlab::Cache::Import::Caching.increment(counter_key)
        end

        def summary(project)
          OPERATIONS.each_with_object({}) do |operation, result|
            result[operation] = {}

            Gitlab::Cache::Import::Caching.values_from_set(counter_list_key(project, operation)).sort.each do |counter|
              humanized_name = counter.split('/').last
              result[operation][humanized_name] = Gitlab::Cache::Import::Caching.read_integer(counter)
            end
          end
        end

        private

        def add_counter_to_list(project, operation, key)
          Gitlab::Cache::Import::Caching.set_add(counter_list_key(project, operation), key)
        end

        def counter_list_key(project, operation)
          COUNTER_LIST_KEY % { project: project.id, operation: operation }
        end

        def validate_operation!(operation)
          unless operation.presence_in(OPERATIONS)
            raise ArgumentError, "Operation must be #{OPERATIONS.join(' or ')}"
          end
        end
      end
    end
  end
end
