# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Cache::Helpers, :use_clean_rails_redis_caching do
  subject(:instance) { Class.new.include(described_class).new }

  let_it_be(:project) { create(:project, :repository) }
  let_it_be(:user) { create(:user) }

  let(:serializer) { MergeRequestSerializer.new(current_user: user, project: project) }

  before do
    # We have to stub #render as it's a Rails controller method unavailable in
    # the module by itself
    allow(instance).to receive(:render) { |data| data[:json] }
    allow(instance).to receive(:current_user) { user }
  end

  describe "#render_cached" do
    subject do
      instance.render_cached(presentable, **kwargs)
    end

    let(:kwargs) do
      {
        with: serializer,
        project: project
      }
    end

    context "single object" do
      let_it_be(:presentable) { create(:merge_request, source_project: project, source_branch: 'wip') }

      it "uses the serializer" do
        expect(serializer).to receive(:represent).with(presentable, project: project)

        subject
      end

      it "is valid JSON" do
        expect(subject).to be_a(Hash)
        expect(subject["id"]).to eq(presentable.id)
      end

      it "fetches from the cache" do
        expect(instance.cache).to receive(:fetch).with("#{serializer.class.name}:#{presentable.cache_key}:#{user.cache_key}", expires_in: described_class::DEFAULT_EXPIRY).once

        subject
      end

      context "when a cache context is supplied" do
        before do
          kwargs[:cache_context] = -> (_) { 'cache-context-key' }
        end

        it "uses the context to augment the cache key" do
          expect(instance.cache).to receive(:fetch).with("#{serializer.class.name}:#{presentable.cache_key}:cache-context-key", expires_in: described_class::DEFAULT_EXPIRY).once

          subject
        end
      end

      context "when expires_in is supplied" do
        it "sets the expiry when accessing the cache" do
          kwargs[:expires_in] = 7.days

          expect(instance.cache).to receive(:fetch).with("#{serializer.class.name}:#{presentable.cache_key}:#{user.cache_key}", expires_in: 7.days).once

          subject
        end
      end
    end

    context "for a collection of objects" do
      let_it_be(:presentable) do
        [
          create(:merge_request, source_project: project, source_branch: 'fix'),
          create(:merge_request, source_project: project, source_branch: 'master')
        ]
      end

      it "uses the serializer" do
        presentable.each do |merge_request|
          expect(serializer).to receive(:represent).with(merge_request, project: project)
        end

        subject
      end

      it "is valid JSON" do
        expect(subject).to be_an(Array)

        presentable.each_with_index do |merge_request, i|
          expect(subject[i]["id"]).to eq(merge_request.id)
        end
      end

      it "fetches from the cache" do
        keys = presentable.map { |merge_request| "#{serializer.class.name}:#{merge_request.cache_key}:#{user.cache_key}" }

        expect(instance.cache).to receive(:fetch_multi).with(*keys, expires_in: described_class::DEFAULT_EXPIRY).once.and_call_original

        subject
      end

      context "when a cache context is supplied" do
        before do
          kwargs[:cache_context] = -> (_) { 'cache-context-key' }
        end

        it "uses the context to augment the cache key" do
          keys = presentable.map { |merge_request| "#{serializer.class.name}:#{merge_request.cache_key}:cache-context-key" }

          expect(instance.cache).to receive(:fetch_multi).with(*keys, expires_in: described_class::DEFAULT_EXPIRY).once.and_call_original

          subject
        end
      end

      context "expires_in is supplied" do
        it "sets the expiry when accessing the cache" do
          keys = presentable.map { |merge_request| "#{serializer.class.name}:#{merge_request.cache_key}:#{user.cache_key}" }
          kwargs[:expires_in] = 7.days

          expect(instance.cache).to receive(:fetch_multi).with(*keys, expires_in: 7.days).once.and_call_original

          subject
        end
      end
    end
  end
end
