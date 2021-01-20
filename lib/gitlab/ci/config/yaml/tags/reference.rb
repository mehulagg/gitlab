# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module YAML
        class Tags
          class Reference < Base
            attr_accessor :resolved, :resolved_value, :data

            def self.tag
              '!reference'
            end

            def valid?
              data[:seq].is_a?(Array) &&
                data[:seq].size > 0 &&
                data[:seq].all? { |identifier| identifier.is_a?(String) }
            end

            private

            def location
              data[:seq].to_a.map(&:to_sym)
            end

            def _resolve(config)
              object = config.dig(*location)
              case object
              when nil
                raise Tags::MissingReferenceError, missing_ref_error_message
              when Tags::Base
                object.resolve(config)
              when Array
                object.map { |value| resolve_wrapper(value, config)}
              when Hash
                self.class.deep_resolve(object, config)
              else
                object
              end
            end

            def circular_error_message
              "#{data[:tag]} #{data[:seq].inspect} is part of a circular chain"
            end

            def missing_ref_error_message
              "#{data[:tag]} #{data[:seq].inspect} could not be found"
            end
          end
        end
      end
    end
  end
end
