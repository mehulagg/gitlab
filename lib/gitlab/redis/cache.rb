# frozen_string_literal: true

# please require all dependencies below:
require_relative 'wrapper' unless defined?(::Rails) && ::Rails.root.present?

module Gitlab
  module Redis
    class Cache < ::Gitlab::Redis::Wrapper
      CACHE_NAMESPACE = 'cache:gitlab'

      class << self
        def default_url
          'redis://localhost:6380'
        end
      end
    end
  end
end
