# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module YAML
        class Tags
          class TagError < StandardError; end
          class CircularReferenceError < TagError; end
          class MissingReferenceError < Tags::TagError; end
          class NotValidError < TagError; end

          attr_accessor :config

          def self.available_tags
            @available_tags ||= [
              Flatten,
              Reference
            ]
          end

          def self.load_custom_tags_into_psych
            available_tags.each { |klass| Psych.add_tag(klass.tag, klass) }
          end

          def initialize(config)
            @config = config.deep_dup
          end

          def to_hash
            Flatten.deep_resolve(config)
          end
        end
      end
    end
  end
end
