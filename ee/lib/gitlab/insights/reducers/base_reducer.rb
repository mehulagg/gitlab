# frozen_string_literal: true

module Gitlab
  module Insights
    module Reducers
      class BaseReducer
        BaseReducerError = Class.new(StandardError)

        def self.reduce(issuables, **args)
          new(issuables, **args).reduce
        end

        def initialize(issuables, **_args)
          @issuables = issuables
        end
        private_class_method :new

        # Should return an insights hash.
        def reduce
          raise NotImplementedError
        end

        def issuable_type
          # `issuables.class` would be `Issue::ActiveRecord_Relation` / `MergeRequest::ActiveRecord_Relation` here
          @issuable_type ||= issuables.class.to_s.underscore.split('/').first.to_sym
        end

        private

        attr_reader :issuables
      end
    end
  end
end
