# frozen_string_literal: true

module Gitlab
  module Cache
    SubjectLacksRequiredMethodError = Class.new(StandardError)

    class << self
      def cross_cache_key(subject, key_method: :cache_key)
        return "" if subject.nil?
        raise SubjectLacksRequiredMethodError unless subject.respond_to?(key_method)

        if key_method == :cache_key
          type, key = *subject.send(key_method).split("/", 2)

          "#{type}/{#{key}}"
        else
          "#{subject.class.to_s.underscore}/{#{subject.send(key_method)}}"
        end
      end
    end
  end
end
