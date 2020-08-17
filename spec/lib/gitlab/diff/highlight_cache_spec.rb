# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Diff::HighlightCache, :clean_gitlab_redis_cache do
  let(:merge_request) { create(:merge_request_with_diffs) }
  let(:diff_hash) do
    { ".gitignore-false-false-false" =>
      [{ line_code: nil, rich_text: nil, text: "@@ -17,3 +17,4 @@ rerun.txt", type: "match", index: 0, old_pos: 17, new_pos: 17 },
       { line_code: "a5cc2925ca8258af241be7e5b0381edf30266302_17_17",
        rich_text: " <span id=\"LC17\" class=\"line\" lang=\"plaintext\">pickle-email-*.html</span>\n",
        text: " pickle-email-*.html",
        type: nil,
        index: 1,
        old_pos: 17,
        new_pos: 17 },
       { line_code: "a5cc2925ca8258af241be7e5b0381edf30266302_18_18",
        rich_text: " <span id=\"LC18\" class=\"line\" lang=\"plaintext\">.project</span>\n",
        text: " .project",
        type: nil,
        index: 2,
        old_pos: 18,
        new_pos: 18 },
       { line_code: "a5cc2925ca8258af241be7e5b0381edf30266302_19_19",
        rich_text: " <span id=\"LC19\" class=\"line\" lang=\"plaintext\">config/initializers/secret_token.rb</span>\n",
        text: " config/initializers/secret_token.rb",
        type: nil,
        index: 3,
        old_pos: 19,
        new_pos: 19 },
       { line_code: "a5cc2925ca8258af241be7e5b0381edf30266302_20_20",
        rich_text: "+<span id=\"LC20\" class=\"line\" lang=\"plaintext\">.DS_Store</span>",
        text: "+.DS_Store",
        type: "new",
        index: 4,
        old_pos: 20,
        new_pos: 20 }] }
  end

  let(:cache_key) { cache.key }

  subject(:cache) { described_class.new(merge_request.diffs) }

  describe '#decorate' do
    # Manually creates a Diff::File object to avoid triggering the cache on
    # the FileCollection::MergeRequestDiff
    let(:diff_file) do
      diffs = merge_request.diffs
      raw_diff = diffs.diffable.raw_diffs(diffs.diff_options.merge(paths: ['CHANGELOG'])).first
      Gitlab::Diff::File.new(raw_diff,
                             repository: diffs.project.repository,
                             diff_refs: diffs.diff_refs,
                             fallback_diff_refs: diffs.fallback_diff_refs)
    end

    before do
      cache.write_if_empty
      cache.decorate(diff_file)
    end

    it 'does not calculate highlighting when reading from cache' do
      expect_any_instance_of(Gitlab::Diff::Highlight).not_to receive(:highlight)

      diff_file.highlighted_diff_lines
    end

    it 'assigns highlighted diff lines to the DiffFile' do
      expect(diff_file.highlighted_diff_lines.size).to be > 5
    end

    it 'assigns highlighted diff lines which rich_text are HTML-safe' do
      rich_texts = diff_file.highlighted_diff_lines.map(&:rich_text)

      expect(rich_texts).to all(be_html_safe)
    end
  end

  shared_examples 'caches missing entries' do
    it 'filters the key/value list of entries to be caches for each invocation' do
      expect(cache).to receive(:write_to_redis_hash)
        .with(hash_including(*paths))
        .once
        .and_call_original

      2.times { cache.write_if_empty }
    end

    it 'reads from cache once' do
      expect(cache).to receive(:read_cache).once.and_call_original

      cache.write_if_empty
    end
  end

  describe '#write_if_empty' do
    it_behaves_like 'caches missing entries' do
      let(:paths) { merge_request.diffs.raw_diff_files.select(&:text?).map(&:file_path) }
    end

    it 'updates memory usage metrics if Redis version >= 4' do
      allow_next_instance_of(Redis) do |redis|
        allow(redis).to receive(:info).and_return({ "redis_version" => "4.0.0" })

        expect(described_class.gitlab_redis_diff_caching_memory_usage_bytes)
          .to receive(:observe).and_call_original

        cache.send(:write_to_redis_hash, diff_hash)
      end
    end

    it 'does not update memory usage metrics if Redis version < 4' do
      allow_next_instance_of(Redis) do |redis|
        allow(redis).to receive(:info).and_return({ "redis_version" => "3.0.0" })

        expect(described_class.gitlab_redis_diff_caching_memory_usage_bytes)
          .not_to receive(:observe)

        cache.send(:write_to_redis_hash, diff_hash)
      end
    end

    context 'different diff_collections for the same diffable' do
      before do
        cache.write_if_empty
      end

      it 'writes an uncached files in the collection to the same redis hash' do
        Gitlab::Redis::Cache.with { |r| r.hdel(cache_key, "files/whitespace") }

        expect { cache.write_if_empty }
          .to change { Gitlab::Redis::Cache.with { |r| r.hgetall(cache_key) } }
      end
    end

    context 'when cache initialized with MergeRequestDiffBatch' do
      let(:merge_request_diff_batch) do
        Gitlab::Diff::FileCollection::MergeRequestDiffBatch.new(
          merge_request.merge_request_diff,
          1,
          10,
          diff_options: nil)
      end

      it_behaves_like 'caches missing entries' do
        let(:cache) { described_class.new(merge_request_diff_batch) }
        let(:paths) { merge_request_diff_batch.raw_diff_files.select(&:text?).map(&:file_path) }
      end
    end
  end

  describe '#write_to_redis_hash' do
    it 'creates or updates a Redis hash' do
      expect { cache.send(:write_to_redis_hash, diff_hash) }
        .to change { Gitlab::Redis::Cache.with { |r| r.hgetall(cache_key) } }
    end
  end

  describe '#clear' do
    it 'clears cache' do
      expect_any_instance_of(Redis).to receive(:del).with(cache_key)

      cache.clear
    end
  end

  describe "GZip usage" do
    let(:diff_file) do
      diffs = merge_request.diffs
      raw_diff = diffs.diffable.raw_diffs(diffs.diff_options.merge(paths: ['CHANGELOG'])).first
      Gitlab::Diff::File.new(raw_diff,
                             repository: diffs.project.repository,
                             diff_refs: diffs.diff_refs,
                             fallback_diff_refs: diffs.fallback_diff_refs)
    end

    it "uses ActiveSupport::Gzip when reading from the cache" do
      expect(ActiveSupport::Gzip).to receive(:decompress).at_least(:once).and_call_original

      cache.write_if_empty
      cache.decorate(diff_file)
    end

    it "uses ActiveSupport::Gzip to compress data when writing to cache" do
      expect(ActiveSupport::Gzip).to receive(:compress).and_call_original

      cache.send(:write_to_redis_hash, diff_hash)
    end
  end

  describe 'metrics' do
    let(:transaction) { Gitlab::Metrics::WebTransaction.new({} ) }

    before do
      allow(cache).to receive(:current_transaction).and_return(transaction)
    end

    it 'observes :gitlab_redis_diff_caching_memory_usage_bytes' do
      expect(transaction)
        .to receive(:observe).with(:gitlab_redis_diff_caching_memory_usage_bytes, a_kind_of(Numeric))

      cache.write_if_empty
    end
  end
end
