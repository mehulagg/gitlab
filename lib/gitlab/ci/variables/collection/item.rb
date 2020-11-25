# frozen_string_literal: true

module Gitlab
  module Ci
    module Variables
      class Collection
        class Item
          def initialize(key:, value:, public: true, file: false, masked: false)
            raise ArgumentError, "`#{key}` must be of type String or nil value, while it was: #{value.class}" unless
              value.is_a?(String) || value.nil?

            @variable = {
              key: key, value: value, public: public, file: file, masked: masked
            }
          end

          def [](key)
            @variable.fetch(key)
          end

          def ==(other)
            to_runner_variable == self.class.fabricate(other).to_runner_variable
          end

          ##
          # If `file: true` has been provided we expose it, otherwise we
          # don't expose `file` attribute at all (stems from what the runner
          # expects).
          #
          def to_runner_variable
            @variable.reject do |hash_key, hash_value|
              hash_key == :file && hash_value == false
            end
          end

          def self.fabricate(resource)
            case resource
            when Hash
              self.new(**resource.symbolize_keys)
            when ::Ci::HasVariable
              self.new(**resource.to_runner_variable)
            when self
              resource.dup
            else
              raise ArgumentError, "Unknown `#{resource.class}` variable resource!"
            end
          end

          def self.each_reference(variable, variables_h, &_block)
            return variable[:value] if Feature.disabled?(:variable_inside_variable)

            # return if self[:raw]

            return variable[:value] if variable[:raw]

            raise ArgumentError, "`#{variables_h}` must be of type Hash or nil value, while it was: #{variables_h.class}" unless
              variables_h.is_a?(::Hash) || variables_h.nil?

            variable[:value].scan(ExpandVariables::VARIABLES_REGEXP) do |var_ref|
              ref_var_name = var_ref.compact.first.to_s
              ref_var = variables_h.fetch(ref_var_name, nil)
              yield ref_var if ref_var
            end
          end

          def self.expand_runner_variable(variable, variables_h)
            value = variable[:value]

            return value if Feature.disabled?(:variable_inside_variable)

            # return value if self[:raw]

            raise ArgumentError, "`#{variables_h}` must be of type Hash or nil value, while it was: #{variables_h.class}" unless
              variables_h.is_a?(::Hash) || variables_h.nil?

            variable[:value] = value.gsub(ExpandVariables::VARIABLES_REGEXP) do |var_ref|
              ref_var_name = variable_name_from(var_ref)
              ref_var = variables_h.fetch(ref_var_name, nil)

              # Leave unknown variables untouched
              next var_ref unless ref_var

              # Return resolved value
              ref_var[:value]
            end
          end

          def self.valid_variable_ref?(ref)
            ref.start_with?('$') || (ref.start_with?('%') && ref.end_with?('%'))
          end

          def self.variable_name_from(ref)
            raise InvalidVariableReference unless valid_variable_ref?(ref)

            return ref[1..-2] if ref.start_with?('%') && ref.end_with?('%')
            return ref[2..-2] if ref.start_with?('${')

            ref[1..-1]
          end

          private_class_method :valid_variable_ref?
        end
      end

      # InvalidVariableReference is raised if a variable reference name is invalid
      class InvalidVariableReference < StandardError
        def initialize(msg = 'Invalid variable reference')
          super
        end
      end
    end
  end
end
