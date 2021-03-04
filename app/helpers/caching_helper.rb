# frozen_string_literal: true

module CachingHelper
  def kit_cache_chunky(*keys)
    @key_blocks = {}

    big_ol_strang = capture do
      yield
    end

    chunks = Rails.cache.fetch_multi(*@key_blocks.keys) do |missing_key|
      capture do
        @key_blocks[missing_key].call
      end
    end

    chunks.each do |key, chunk|
      big_ol_strang.gsub!(key, (chunk || ""))
    end

    big_ol_strang.html_safe
  end

  def cache_chunk(*keys, &block)
    key = keys.join(":")

    @key_blocks[key] = block

    return key
  end
end
