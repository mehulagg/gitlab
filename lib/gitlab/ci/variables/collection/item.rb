# frozen_string_literal: true

module Gitlab
  module Ci
    module Variables
      class Collection
        class Item
          include Gitlab::Utils::StrongMemoize

          def initialize(key:, value:, public: true, file: false, masked: false, raw: false, depends_on: nil)
            raise ArgumentError, "`#{key}` must be of type String or nil value, while it was: #{value.class}" unless
              value.is_a?(String) || value.nil?

            @variable = {
              key: key, value: value, public: public, file: file, masked: masked
            }
            @variable[:raw] = true if raw

            depends_on ||= variable_references
            @variable[:depends_on] = depends_on if depends_on
          end

          def [](key)
            return false if key == :raw && !@variable.has_key?(:raw)
            return if key == :depends_on && !@variable.has_key?(:depends_on)

            @variable.fetch(key)
          end

          def merge(*other_hashes)
            self.class.fabricate(@variable.merge(*other_hashes))
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

          private

          def variable_references
            return if self[:raw]

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
