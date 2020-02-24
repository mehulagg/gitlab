# frozen_string_literal: true

require "oj"

module Grape
  module Formatter
    module Json
      class << self
        def call(object, _env)
          Oj.dump(object)
        end
      end
    end
  end
end
