# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module YAML
        class Tags
          class Flatten < Base
            def self.tag
              '!flatten'
            end

            def valid?
              data[:seq].is_a?(Array) && !data[:scalar].present?
            end

            private

            def _resolve(config)
              data[:seq]
                .map { |object| symbolize_names! resolve_wrapper(object, config) }
                .flatten
            end

            def symbolize_names!(result)
              case result
              when Hash
                result.keys.each do |key|
                  result[key.to_sym] = symbolize_names!(result.delete(key))
                end
              when Array
                result.map!(&method(:symbolize_names!))
              end
              result
            end
          end
        end
      end
    end
  end
end
