# frozen_string_literal: true

module Gitlab
  module Ci
    module Variables
      class Collection
        include Enumerable

        def initialize(variables = [])
          @variables = []

          variables.each { |variable| self.append(variable) }
        end

        def append(resource)
          tap { @variables.append(Collection::Item.fabricate(resource)) }
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

        def to_runner_variables
          runner_vars = self.map(&:to_runner_variable)
          return runner_vars if Feature.disabled?(:variable_inside_variable)

          # Perform a topological sort and inline expansion on variable clones
          runner_vars_h = runner_vars.map { |env| [env.fetch(:key), env.dup] }.to_h
          begin
            each_node = ->(&b) { runner_vars_h.each_value(&b) }
            each_child = ->(v, &b) { Collection::Item.each_reference(v, runner_vars_h, &b) }

            TSort.tsort_each(each_node, each_child) { |v| Collection::Item.expand_runner_variable(v, runner_vars_h) }
          rescue TSort::Cyclic => e
            raise CyclicVariableReference, e.message
          end

          runner_vars_h.values
        end

        def to_hash
          self.to_runner_variables
            .map { |env| [env.fetch(:key), env.fetch(:value)] }
            .to_h.with_indifferent_access
        end
      end

      # CyclicVariableReference is raised if a cyclic dependency is detected
      CyclicVariableReference = Class.new(StandardError)
    end
  end
end
