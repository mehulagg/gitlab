# frozen_string_literal: true

module Gitlab
  module Ci
    module Variables
      class Collection
        class Item
          include Gitlab::Utils::StrongMemoize

          attr_reader :raw

          def initialize(key:, value:, public: true, file: false, masked: false, raw: false)
            raise ArgumentError, "`#{key}` must be of type String or nil value, while it was: #{value.class}" unless
              value.is_a?(String) || value.nil?

            @variable = { key: key, value: value, public: public, file: file, masked: masked }
            @raw = raw
          end

          def value
            @variable.fetch(:value)
          end

          def [](key)
            @variable.fetch(key)
          end

          def ==(other)
            to_runner_variable == self.class.fabricate(other).to_runner_variable
          end

          def depends_on
            strong_memoize(:depends_on) do
              next if raw

              next unless ExpandVariables.possible_var_reference?(value)

              value.scan(ExpandVariables::VARIABLES_REGEXP).map(&:first)
            end
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
        end
      end
    end
  end
end
