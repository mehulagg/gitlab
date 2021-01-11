# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      class Extendable
        include Enumerable

        ExtensionError = Class.new(StandardError)

        def initialize(hash)
          @hash = hash

          each { |entry| entry.extend! if entry.extensible? }
        end

        def each
          @hash.each_key do |key|
            yield Extendable::Entry.new(key, @hash)
          end
        end

        def to_hash
          @hash
        end
      end
    end
  end
end
