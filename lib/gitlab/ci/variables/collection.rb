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
          begin
            input_vars = runner_vars.index_by { |env| env.fetch(:key) }
            sorted_var_values = {}
            runner_vars.clear
            each_node = ->(&b) { input_vars.each_key(&b) }
            each_child = ->(k, &b) { ExpandVariables.each_variable_reference(input_vars.dig(k, :value), input_vars, &b) }

            TSort.tsort(each_node, each_child).each do |key|
              env = input_vars.fetch(key)
              new_value = ExpandVariables.expand_existing(env[:value], sorted_var_values)
              sorted_var_values.store(key, new_value)
              runner_vars.push(env.merge({ value: new_value }))
            end
          rescue TSort::Cyclic => e
            raise CyclicVariableReference, e.message
          end

          runner_vars
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
