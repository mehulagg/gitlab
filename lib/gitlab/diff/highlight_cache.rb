# frozen_string_literal: true
#
module Gitlab
  module Diff
    class HighlightCache
      include Gitlab::Utils::StrongMemoize

      EXPIRATION = 1.week
      VERSION = 1

      delegate :diffable,     to: :@diff_collection
      delegate :diff_options, to: :@diff_collection

      def initialize(diff_collection)
        @diff_collection = diff_collection
      end

      # - Reads from cache
      # - Assigns DiffFile#highlighted_diff_lines for cached files
      #
      def decorate(diff_file)
        if content = read_file(diff_file)
          diff_file.highlighted_diff_lines = content.map do |line|
            Gitlab::Diff::Line.safe_init_from_hash(line)
          end
        end
      end

      # For every file that isn't already contained in the redis hash, store the
      #   result of #highlighted_diff_lines, then submit the uncached content
      #   to #write_to_redis_hash to submit a single write. This avoids excessive
      #   IO generated by N+1's (1 writing for each highlighted line or file).
      #
      def write_if_empty
        return if cacheable_files.empty?

        new_cache_content = {}

        cacheable_files.each do |diff_file|
          new_cache_content[diff_file.file_path] = diff_file.highlighted_diff_lines.map(&:to_hash)
        end

        write_to_redis_hash(new_cache_content)
      end

      def clear
        Gitlab::Redis::Cache.with do |redis|
          redis.del(key)
        end
      end

      def key
        strong_memoize(:redis_key) do
          ['highlighted-diff-files', diffable.cache_key, VERSION, diff_options].join(':')
        end
      end

      private

      # We create a Gitlab::Diff::DeprecatedHighlightCache here in order to
      #   expire deprecated cache entries while we make the transition. This can
      #   be removed when :hset_redis_diff_caching is fully launched.
      # See https://gitlab.com/gitlab-org/gitlab/issues/38008
      #
      def deprecated_cache
        strong_memoize(:deprecated_cache) do
          Gitlab::Diff::DeprecatedHighlightCache.new(@diff_collection)
        end
      end

      def cacheable_files
        strong_memoize(:cacheable_files) do
          diff_files.select { |file| cacheable?(file) && read_file(file).nil? }
        end
      end

      # Given a hash of:
      #   { "file/to/cache" =>
      #   [ { line_code: "a5cc2925ca8258af241be7e5b0381edf30266302_19_19",
      #       rich_text: " <span id=\"LC19\" class=\"line\" lang=\"plaintext\">config/initializers/secret_token.rb</span>\n",
      #       text: " config/initializers/secret_token.rb",
      #       type: nil,
      #       index: 3,
      #       old_pos: 19,
      #       new_pos: 19 }
      #   ] }
      #
      #   ...it will write/update a Gitlab::Redis hash (HSET)
      #
      def write_to_redis_hash(hash)
        Gitlab::Redis::Cache.with do |redis|
          redis.pipelined do
            hash.each do |diff_file_id, highlighted_diff_lines_hash|
              redis.hset(key, diff_file_id, highlighted_diff_lines_hash.to_json)
            end

            # HSETs have to have their expiration date manually updated
            #
            redis.expire(key, EXPIRATION)
          end
        end

        # Subsequent read_file calls would need the latest cache.
        #
        clear_memoization(:cached_content)
        clear_memoization(:cacheable_files)

        # Clean up any deprecated hash entries
        #
        deprecated_cache.clear
      end

      def file_paths
        strong_memoize(:file_paths) do
          diff_files.collect(&:file_path)
        end
      end

      def read_file(diff_file)
        cached_content[diff_file.file_path]
      end

      def cached_content
        strong_memoize(:cached_content) { read_cache }
      end

      def read_cache
        return {} unless file_paths.any?

        results = []

        Gitlab::Redis::Cache.with do |redis|
          results = redis.hmget(key, file_paths)
        end

        results.map! do |result|
          JSON.parse(result, symbolize_names: true) unless result.nil?
        end

        file_paths.zip(results).to_h
      end

      def cacheable?(diff_file)
        diffable.present? && diff_file.text? && diff_file.diffable?
      end

      def diff_files
        # We access raw_diff_files here, as diff_files will attempt to apply the
        #   highlighting code found in this class, leading  to a circular
        #   reference.
        #
        @diff_collection.raw_diff_files
      end
    end
  end
end
