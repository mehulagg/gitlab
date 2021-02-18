# frozen_string_literal: true

module Gitlab
  module Ci
    module Variables
      class Collection
        class Item
          include Gitlab::Utils::StrongMemoize

          def initialize(key:, value:, public: true, file: false, masked: false, depends_on: nil)
            raise ArgumentError, "`#{key}` must be of type String or nil value, while it was: #{value.class}" unless
              value.is_a?(String) || value.nil?

            depends_on ||= variable_references

            @variable = {
              key: key,
              value: value,
              public: public,
              file: file,
              masked: masked,
              depends_on: depends_on
            }
          end

          def [](key)
            @variable.fetch(key)
          end

          def ==(other)
            to_runner_variable == self.class.fabricate(other).to_runner_variable
          end

          def depends_on
            self[:depends_on]
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

          private

          def variable_references
            value = @variable.fetch(:value)
            return unless ExpandVariables.possible_var_reference?(value)

            value.scan(ExpandVariables::VARIABLES_REGEXP).map do |var_ref|
              var_ref.first
            end
          end
        end
      end
    end
  end
end
