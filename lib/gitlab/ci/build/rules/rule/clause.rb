# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      class Rules::Rule::Clause
        ##
        # Abstract class that defines an interface of a single
        # job rule specification.
        #
        # Used for job's inclusion rules configuration.
        #
        UnknownClauseError = Class.new(StandardError)

        def self.fabricate(type, value)
          # We use const_get and rescue NameError because `safe_constantize` resolves `Variables`
          # to a different class/module, even when using `"::#{self}::#{type.to_s.camelize}".safe_constantize`
          const_get(type.to_s.camelize).new(value)
        rescue NameError
        end

        def initialize(spec)
          @spec = spec
        end

        def satisfied_by?(pipeline, context = nil)
          raise NotImplementedError
        end
      end
    end
  end
end
