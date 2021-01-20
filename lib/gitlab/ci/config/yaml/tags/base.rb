# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module YAML
        class Tags
          class Base
            attr_accessor :resolved, :resolved_value, :data

            class << self
              def deep_resolve(config, data = nil)
                config.deep_transform_values do |object|
                  resolve_wrapper(object, data || config)
                end
              end

              def resolve_wrapper(object, config)
                if object.respond_to?(:resolve)
                  object.resolve(config)
                else
                  object
                end
              end
            end

            def init_with(coder)
              @data = {
                tag: coder.tag,
                style: coder.style,
                seq: coder.seq,
                scalar: coder.scalar,
                map: coder.map
              }
            end

            def valid?
              false
            end

            def resolve(config)
              raise Tags::NotValidError, validation_error_message unless valid?
              raise Tags::CircularReferenceError, circular_error_message if resolving?
              return resolved_value if resolved?

              self.resolved = :in_progress
              self.resolved_value = _resolve(config)
              self.resolved = :done
              resolved_value
            end

            private
            delegate :resolve_wrapper, to: :class

            def resolved?
              resolved == :done
            end

            def resolving?
              resolved == :in_progress
            end

            def circular_error_message
              "#{data[:tag]} #{data[:seq].inspect} is part of a circular chain"
            end

            def validation_error_message
              "#{data[:tag]} #{(data[:scalar].presence || data[:seq]).inspect} is not valid"
            end
          end
        end
      end
    end
  end
end
