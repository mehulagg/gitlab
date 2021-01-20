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
                .map { |object| resolve_wrapper(object, config) }
                .flatten
            end
          end
        end
      end
    end
  end
end
