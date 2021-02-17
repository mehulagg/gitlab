# frozen_string_literal: true

module Gitlab
  module Ci
    module Variables
      class Collection
        include Enumerable

        attr_reader :errors

        def initialize(variables = [], errors = nil)
          @variables = []
          @var_hash = {}
          @errors = errors

          variables.each { |variable| self.append(variable) }
        end

        def append(resource)
          tap do
            item = Collection::Item.fabricate(resource)
            @variables.append(item)
            @var_hash[item[:key]] = item
          end
        end

        def concat(resources)
          return self if resources.nil?

          tap { resources.each { |variable| self.append(variable) } }
        end

        def each
          @variables.each { |variable| yield variable }
        end

        def +(other)
          self.class.new.tap do |collection|
            self.each { |variable| collection.append(variable) }
            other.each { |variable| collection.append(variable) }
          end
        end

        def [](key)
          @var_hash[key]
        end

        def size
          @variables.size
        end

        def to_runner_variables
          self.map(&:to_runner_variable)
        end

        def include?(obj)
          return false unless obj.is_a?(Hash) && obj.has_key?(:key)

          key = obj.fetch(:key)
          found_var = @var_hash[key]
          !found_var.nil? && found_var.to_runner_variable == Collection::Item.fabricate(obj).to_runner_variable
        end

        def to_hash
          self.to_runner_variables
            .map { |env| [env.fetch(:key), env.fetch(:value)] }
            .to_h.with_indifferent_access
        end

        def ==(other)
          return false unless other.class == self.class

          @variables == other.variables
        end

        # Returns a sorted Collection object, and sets errors property in case of an error
        def sorted_collection(project)
          Sorted.new(self, project).sort
        end

        protected

        attr_reader :variables
      end
    end
  end
end
