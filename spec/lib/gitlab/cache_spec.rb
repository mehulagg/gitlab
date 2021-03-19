# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitlab::Cache, :request_store do
  describe "#fetch_once" do
    subject do
      Proc.new do
        described_class.fetch_once([:test, "key"], expires_in: 10.minutes) do
          "return value"
        end
      end
    end

    it "fetches from the cache once" do
      expect(Rails.cache).to receive(:fetch).once.with([:test, "key"], expires_in: 10.minutes).and_call_original

      expect(subject.call).to eq("return value")
      expect(subject.call).to eq("return value")
    end

    it "always returns from the request store" do
      expect(Gitlab::SafeRequestStore).to receive(:fetch).with([:test, "key"]).exactly(2).times.and_call_original

      expect(subject.call).to eq("return value")
      expect(subject.call).to eq("return value")
    end
  end
end
