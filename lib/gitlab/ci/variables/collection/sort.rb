# frozen_string_literal: true

module Gitlab
  module Ci
    module Variables
      class Collection
        class Sort
          include TSort
          include Gitlab::Utils::StrongMemoize

          def initialize(collection, project)
            raise(ArgumentError, "A Gitlab::Ci::Variables::Collection object was expected") unless
              collection.is_a?(Collection)

            @collection = collection
            @project = project
          end

          def valid?
            errors.nil?
          end

          # errors sorts an array of variables, ignoring unknown variable references,
          # and returning an error string if a circular variable reference is found
          def errors
            return if Feature.disabled?(:variable_inside_variable, @project)

            strong_memoize(:errors) do
              # Check for cyclic dependencies and build error message in that case
              cyclic_vars = each_strongly_connected_component.filter_map do |component|
                component.map { |v| v[:key] }.inspect if component.size > 1
              end

              "circular variable reference detected: #{cyclic_vars.join(', ')}" if cyclic_vars.any?
            end
          end

          # collection sorts a collection of variables, ignoring unknown variable references.
          # If a circular variable reference is found, a new collection with the original array and an error is returned
          def collection
            return @collection if Feature.disabled?(:variable_inside_variable, @project)

            return Gitlab::Ci::Variables::Collection.new(@collection, errors) if errors

            Gitlab::Ci::Variables::Collection.new(tsort)
          end

          private

          def tsort_each_node(&block)
            @collection.each(&block)
          end

          def tsort_each_child(var_item, &block)
            depends_on = var_item.depends_on
            return unless depends_on

            depends_on.filter_map { |var_ref_name| @collection[var_ref_name] }.each(&block)
          end
        end
      end
    end
  end
end
