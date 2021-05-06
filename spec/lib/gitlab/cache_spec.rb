# frozen_string_literal: true

require "spec_helper"

RSpec.describe Gitlab::Cache, :with_clean_rails_cache do
  describe "#cross_cache_key" do
    subject { described_class.cross_cache_key(object, **kwargs) }

    let(:object) { double("MysteryClass", cache_key: "mystery_class/19-20210322155139973640") }
    let(:kwargs) { {} }

    it { is_expected.to eq("mystery_class/{19-20210322155139973640}") }

    context "object is nil" do
      let(:object) { nil }

      it { is_expected.to eq("") }
    end

    context "cache_key isn't defined" do
      let(:object) { double("MysteryClass") }

      it "raises an error" do
        expect { subject }.to raise_error(described_class::SubjectLacksRequiredMethodError)
      end
    end

    context "alternative key_method is provided" do
      let(:object) { double("MysteryClass", class: "MysteryClass", id: 19) }
      let(:kwargs) do
        { key_method: :id }
      end

      it { is_expected.to eq("mystery_class/{19}") }
    end
  end
end
