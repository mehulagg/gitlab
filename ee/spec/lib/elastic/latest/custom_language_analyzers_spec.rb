# frozen_string_literal: true

require 'fast_spec_helper'

RSpec.describe Elastic::Latest::CustomLanguageAnalyzers do
  describe '.custom_analyzers_fields' do
    before do
      allow(::Gitlab::CurrentSettings).to receive(:elasticsearch_analyzers_smartcn_enabled).and_return(smartcn_enabled)
      allow(::Gitlab::CurrentSettings).to receive(:elasticsearch_analyzers_kuromoji_enabled).and_return(kuromoji_enabled)
    end

    context 'all analyzers disabled' do
      let(:smartcn_enabled) { false }
      let(:kuromoji_enabled) { false }

      it 'returns config' do
        expect(described_class.custom_analyzers_fields(type: :text)).to eq({})
      end
    end

    context 'all analyzers enabled' do
      let(:smartcn_enabled) { true }
      let(:kuromoji_enabled) { true }

      it 'returns config' do
        expect(described_class.custom_analyzers_fields(type: :text)).to eq(smartcn: { analyzer: 'smartcn', type: :text }, kuromoji: { analyzer: 'kuromoji', type: :text })
      end
    end

    context 'smatcn enabled' do
      let(:smartcn_enabled) { true }
      let(:kuromoji_enabled) { false }

      it 'returns config' do
        expect(described_class.custom_analyzers_fields(type: :text)).to eq(smartcn: { analyzer: 'smartcn', type: :text })
      end
    end

    context 'kuromoji enabled' do
      let(:smartcn_enabled) { false }
      let(:kuromoji_enabled) { true }

      it 'returns config' do
        expect(described_class.custom_analyzers_fields(type: :text)).to eq(kuromoji: { analyzer: 'kuromoji', type: :text })
      end
    end
  end

  describe '.add_custom_analyzers_fields' do
    before do
      allow(::Gitlab::CurrentSettings).to receive(:elasticsearch_analyzers_smartcn_search).and_return(smartcn_search)
      allow(::Gitlab::CurrentSettings).to receive(:elasticsearch_analyzers_kuromoji_search).and_return(kuromoji_search)
    end

    context 'all analyzers disabled' do
      let(:smartcn_search) { false }
      let(:kuromoji_search) { false }

      it 'returns correct fields' do
        expect(described_class.add_custom_analyzers_fields(%w(title^2 description))).to match_array(%w(title^2 description))
      end
    end

    context 'all analyzers enabled' do
      let(:smartcn_search) { true }
      let(:kuromoji_search) { true }

      it 'returns correct fields' do
        expect(described_class.add_custom_analyzers_fields(%w(title^2 description))).to match_array(%w(title^2 description title.kuromoji title.smartcn description.kuromoji description.smartcn))
      end
    end
  end
end
