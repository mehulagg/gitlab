# frozen_string_literal: true

module Gitlab
  module Graphql
    module CallsGitaly
      # Check if any `calls_gitaly: true` declarations need to be added
      #
      # See BaseField: this extension is not applied if the field does not
      # need it (i.e. it has a constant complexity or knows that it calls
      # gitaly)
      class FieldExtension < ::GraphQL::Schema::FieldExtension
        def resolve(object:, arguments:, context:, **rest)
          yield(object, arguments, current_gitaly_call_count)
        end

        def after_resolve(value:, memo:, **rest)
          count = current_gitaly_call_count - memo
          calls_gitaly_check(count)

          value
        end

        private

        def current_gitaly_call_count
          Gitlab::GitalyClient.get_request_count || 0
        end

        def calls_gitaly_check(calls)
          return if calls < 1

          # Will inform you if there needs to be `calls_gitaly: true` as a kwarg in the field declaration
          # if there is at least 1 Gitaly call involved with the field resolution.
          field_name = field.graphql_name
          object_name = field.owner_type.graphql_name

          error = RuntimeError.new(<<~ERROR)
            #{object_name}.#{field_name} calls Gitaly!
            Please either specify a constant complexity or add `calls_gitaly: true` to the field declaration
          ERROR
          Gitlab::ErrorTracking.track_and_raise_for_dev_exception(error)
        end
      end
    end
  end
end
