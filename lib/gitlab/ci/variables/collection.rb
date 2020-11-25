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

          # Perform a topological sort and inline expansion on a variable hash
          runner_vars_h = runner_vars.index_by { |env| env.fetch(:key) }
          begin
            each_node = ->(&b) { runner_vars_h.each_value(&b) }
            each_child = ->(env, &b) { ExpandVariables.each_variable_reference(env.fetch(:value), runner_vars_h, &b) }
            runner_var_values_h = {}

            TSort.tsort_each(each_node, each_child) do |key:, value:, **_|
              new_value = ExpandVariables.expand_existing(value, runner_var_values_h)
              runner_var_values_h.store(key, new_value)

              # Update with new value
              runner_vars_h[key][:value] = new_value if new_value != value
            end
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
