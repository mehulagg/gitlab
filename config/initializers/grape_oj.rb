# frozen_string_literal: true

require "oj"

module Grape
  module Formatter
    module Json
      class << self
        def call(object, env)
          if Feature.enabled?(:grape_oj_json_dumping, default_enabled: true)
            new_implementation(object)
          else
            old_implementation(object)
          end
        end

        def old_implementation(object)
          return object.to_json if object.respond_to?(:to_json)

          ::Grape::Json.dump(object)
        end

        def new_implementation(object)
          Oj.dump(object)
        end
      end
    end
  end
end
